//
//  CollectionKit.swift
//  CollectionKit
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import YetAnotherAnimationLibrary

open class CollectionView: UIScrollView {
  public var provider: AnyCollectionProvider = BaseCollectionProvider() {
    didSet {
      setNeedsReload()
    }
  }

  public var presenter: CollectionPresenter = CollectionPresenter()

  public private(set) var hasReloaded = false
  public private(set) var needsReload = true

  public var overlayView = UIView()

  let dragManager = CollectionDragManager()
  public var visibleIndexes: Set<Int> = []
  public var visibleCells: [UIView] { return Array(visibleCellToIndexMap.st.keys) }
  var visibleCellToIndexMap: DictionaryTwoWay<UIView, Int> = [:]
  var identifiersToIndexMap: DictionaryTwoWay<String, Int> = [:]

  var lastLoadBounds: CGRect?
  // TODO: change this to private
  public var floatingCells: Set<UIView> = []
  public var loading = false
  public var reloading = false

  public var tapGestureRecognizer = UITapGestureRecognizer()

  public convenience init(provider: AnyCollectionProvider) {
    self.init()
    self.provider = provider
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
    CollectionViewManager.shared.register(collectionView: self)

    tapGestureRecognizer.addTarget(self, action: #selector(tap(gr:)))
    addGestureRecognizer(tapGestureRecognizer)

    overlayView.isUserInteractionEnabled = false
    overlayView.layer.zPosition = 1000
    addSubview(overlayView)

    panGestureRecognizer.addTarget(self, action: #selector(pan(gr:)))
    dragManager.collectionView = self

    yaal.contentOffset.value.changes.addListener { [weak self] _, newOffset in
      guard let collectionView = self else { return }
      let limit = CGPoint(x: newOffset.x.clamp(collectionView.offsetFrame.minX,
                                               collectionView.offsetFrame.maxX),
                          y: newOffset.y.clamp(collectionView.offsetFrame.minY,
                                               collectionView.offsetFrame.maxY))

      if limit != newOffset {
        collectionView.contentOffset = limit
        collectionView.yaal.contentOffset.stop()
      }
    }
  }

  @objc func tap(gr: UITapGestureRecognizer) {
    for cell in visibleCells {
      if cell.point(inside: gr.location(in: cell), with: nil) {
        provider.didTap(view: cell, at: visibleCellToIndexMap[cell]!)
        return
      }
    }
  }

  func pan(gr:UIPanGestureRecognizer) {
    screenDragLocation = absoluteLocation(for: gr.location(in: self))
    if gr.state == .began {
      yaal.contentOffset.stop()
    }
  }

  open override func layoutSubviews() {
    super.layoutSubviews()
    overlayView.frame = CGRect(origin: contentOffset, size: bounds.size)
    if needsReload {
      reloadData()
    } else if bounds.size != lastLoadBounds?.size {
      invalidateLayout()
    } else if bounds != lastLoadBounds {
      loadCells()
    }
  }

  public var activeFrameSlop: UIEdgeInsets? {
    didSet {
      if !reloading && activeFrameSlop != oldValue {
        loadCells()
      }
    }
  }
  var screenDragLocation: CGPoint = .zero
  var scrollVelocity: CGPoint = .zero
  open override var contentOffset: CGPoint{
    didSet{
      scrollVelocity = contentOffset - oldValue
    }
  }
  var activeFrame: CGRect {
    if let activeFrameSlop = activeFrameSlop {
      return CGRect(x: visibleFrame.origin.x + activeFrameSlop.left, y: visibleFrame.origin.y + activeFrameSlop.top, width: visibleFrame.width - activeFrameSlop.left - activeFrameSlop.right, height: visibleFrame.height - activeFrameSlop.top - activeFrameSlop.bottom)
    } else {
      return visibleFrame
    }
  }

  /*
   * Update visibleCells & visibleIndexes according to scrollView's visibleFrame
   * load cells that move into the visibleFrame and recycles them when
   * they move out of the visibleFrame.
   */
  func loadCells() {
    if loading || reloading || !hasReloaded { return }
    loading = true
    lastLoadBounds = bounds

    var indexes = provider.visibleIndexes(activeFrame: activeFrame).union(floatingCells.map({ return visibleCellToIndexMap[$0]! }))
    let deletedIndexes = visibleIndexes.subtracting(indexes)
    let newIndexes = indexes.subtracting(visibleIndexes)
    for i in deletedIndexes {
      if let cell = visibleCellToIndexMap[i], bounds.intersects(cell.frame) {
        // Dont remove cell if it is still on screen. this is probably because the presenter is doing some animation with the cell
        // which resulted the cell being at a different position. We will remove this cell later.
        indexes.insert(i)
      } else {
        disappearCell(at: i)
      }
    }
    for i in newIndexes {
      appearCell(at: i)
    }
    visibleIndexes = indexes

    if !needsReload {
      for (index, view) in visibleCellToIndexMap.ts {
        if !floatingCells.contains(view) {
          (view.collectionPresenter ?? presenter).update(collectionView:self, view: view, at: index, frame: provider.frame(at: index))
        }
      }
    }
    loading = false
  }
  
  public func invalidateLayout() {
    provider.layout(collectionSize: innerSize)
    contentSize = provider.contentSize
    loadCells()
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (()->CGPoint)? = nil) {
    provider.willReload()
    reloading = true
    needsReload = false
    lastLoadBounds = bounds
    provider.layout(collectionSize: innerSize)

    // ask the delegate for all cell's identifier & frames
    var newIdentifiersToIndexMap: DictionaryTwoWay<String, Int> = [:]
    var newVisibleCellToIndexMap: DictionaryTwoWay<UIView, Int> = [:]
    let itemCount = provider.numberOfItems

    for index in 0..<itemCount {
      let identifier = provider.identifier(at: index)
      if newIdentifiersToIndexMap[identifier] != nil {
        print("[CollectionView] Duplicate Identifier: \(identifier)")
        var i = 2
        var newIdentifier = ""
        repeat {
          newIdentifier = identifier + "\(i)"
          i += 1
        } while newIdentifiersToIndexMap[newIdentifier] != nil
        newIdentifiersToIndexMap[newIdentifier] = index
      } else {
        newIdentifiersToIndexMap[identifier] = index
      }
    }

    let oldContentOffset = contentOffset
    contentSize = provider.contentSize
    if let offset = contentOffsetAdjustFn?() {
      let scrollVelocity = self.scrollVelocity
      contentOffset = offset
      self.scrollVelocity = scrollVelocity
    }
    let contentOffsetDiff = contentOffset - oldContentOffset

    var newVisibleIndexes = provider.visibleIndexes(activeFrame: activeFrame)
    for cell in floatingCells {
      let cellIdentifier = identifiersToIndexMap[visibleCellToIndexMap[cell]!]!
      if let index = newIdentifiersToIndexMap[cellIdentifier] {
        newVisibleIndexes.insert(index)
      } else {
        unfloat(cell: cell)
      }
    }

    let newVisibleIdentifiers = Set(newVisibleIndexes.map { index in
      return newIdentifiersToIndexMap[index]!
    })
    let oldVisibleIdentifiers = Set(visibleIndexes.map { index in
      return identifiersToIndexMap[index]!
    })

    let deletedVisibleIdentifiers = oldVisibleIdentifiers.subtracting(newVisibleIdentifiers)
    let insertedVisibleIdentifiers = newVisibleIdentifiers.subtracting(oldVisibleIdentifiers)
    let existingVisibleIdentifiers = newVisibleIdentifiers.intersection(oldVisibleIdentifiers)

    for identifier in existingVisibleIdentifiers {
      // move the cell to a different index
      let oldIndex = identifiersToIndexMap[identifier]!
      let newIndex = newIdentifiersToIndexMap[identifier]!
      let cell = visibleCellToIndexMap[oldIndex]!

      if !floatingCells.contains(cell) {
        insert(cell: cell)
      }

      newVisibleCellToIndexMap[newIndex] = cell
      provider.update(view: cell, at: newIndex)
      (cell.collectionPresenter ?? presenter).shift(collectionView: self, delta: contentOffsetDiff, view: cell, at: newIndex, frame: provider.frame(at: newIndex))
    }

    for identifier in deletedVisibleIdentifiers {
      disappearCell(at: identifiersToIndexMap[identifier]!)
    }

    visibleIndexes = newVisibleIndexes
    visibleCellToIndexMap = newVisibleCellToIndexMap
    identifiersToIndexMap = newIdentifiersToIndexMap

    for identifier in insertedVisibleIdentifiers {
      appearCell(at: identifiersToIndexMap[identifier]!)
    }

    for (index, view) in visibleCellToIndexMap.ts {
      if !floatingCells.contains(view) {
        (view.collectionPresenter ?? presenter).update(collectionView:self, view: view, at: index, frame: provider.frame(at: index))
      }
    }
    reloading = false
    hasReloaded = true
    provider.didReload()
  }
  
  public func setNeedsReload() {
    needsReload = true
    setNeedsLayout()
  }

  fileprivate func disappearCell(at index: Int) {
    if let cell = visibleCellToIndexMap[index] {
      (cell.collectionPresenter ?? presenter).delete(collectionView: self, view: cell, at: index)
      visibleCellToIndexMap.remove(index)
    }
  }
  fileprivate func appearCell(at index: Int) {
    let cell = provider.view(at: index)
    let frame = provider.frame(at: index)
    cell.bounds.size = frame.bounds.size
    cell.center = frame.center
    provider.update(view: cell, at: index)
    if visibleCellToIndexMap[cell] == nil {
      visibleCellToIndexMap[cell] = index
      insert(cell: cell)
      (cell.collectionPresenter ?? presenter).insert(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))
    }
  }
  fileprivate func insert(cell: UIView) {
    if let index = self.index(for: cell) {
      var currentMin = Int.max
      for cell in subviews {
        if let visibleIndex = visibleCellToIndexMap[cell], visibleIndex > index, visibleIndex < currentMin {
          currentMin = visibleIndex
        }
      }
      if currentMin == Int.max {
        insertSubview(cell, belowSubview: overlayView)
      } else {
        insertSubview(cell, belowSubview: visibleCellToIndexMap[currentMin]!)
      }
    } else {
      insertSubview(cell, belowSubview: overlayView)
    }
  }
}

extension CollectionView {
  public func isFloating(cell: UIView) -> Bool {
    return floatingCells.contains(cell)
  }

  public func float(cell: UIView) {
    if visibleCellToIndexMap[cell] == nil {
      fatalError("Unable to float a cell that is not on screen")
    }
    floatingCells.insert(cell)
    cell.center = overlayView.convert(cell.center, from: cell.superview)
    cell.yaal.center.updateWithCurrentState()
    cell.yaal.center.animateTo(cell.center, stiffness: 300, damping: 25)
    overlayView.addSubview(cell)
  }

  public func unfloat(cell: UIView) {
    guard isFloating(cell: cell) else {
      return
    }

    floatingCells.remove(cell)
    cell.center = self.convert(cell.center, from: cell.superview)
    cell.yaal.center.updateWithCurrentState()
    insert(cell: cell)

    // index & frame should be always avaliable because floating cell is always visible. Otherwise we have a bug
    let index = self.index(for: cell)!
    let frame = provider.frame(at: index)
    cell.yaal.center.animateTo(frame.center, stiffness: 300, damping: 25)
  }
}

extension CollectionView {
  public func indexForCell(at point: CGPoint) -> Int? {
    for index in 0..<provider.numberOfItems {
      let frame = provider.frame(at: index)
      if frame.contains(point) {
        return index
      }
    }
    return nil
  }

  public func index(for cell: UIView) -> Int? {
    return visibleCellToIndexMap[cell]
  }

  public func cell(at index: Int) -> UIView? {
    return visibleCellToIndexMap[index]
  }
}
