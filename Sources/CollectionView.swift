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
  public var provider: AnyCollectionProvider?

  public private(set) var hasReloaded = false

  public var minimumContentSize: CGSize = .zero {
    didSet{
      let newContentSize = CGSize(width: max(minimumContentSize.width, contentSize.width),
                                  height: max(minimumContentSize.height, contentSize.height))
      if newContentSize != contentSize {
        contentSize = newContentSize
      }
    }
  }

  public var numberOfItems: Int {
    return frames.count
  }

  public var overlayView = UIView()

  public var supportOverflow = false

  // the computed frames for cells, constructed in reloadData
  var frames: [CGRect] = []

  // visible indexes & cell
  let visibleIndexesManager = CollectionVisibleIndexesManager()
  let dragManager = CollectionDragManager()
  public var visibleIndexes: Set<Int> = []
  public var visibleCells: [UIView] { return Array(visibleCellToIndexMap.st.keys) }
  var visibleCellToIndexMap: DictionaryTwoWay<UIView, Int> = [:]
  var identifiersToIndexMap: DictionaryTwoWay<String, Int> = [:]

  var lastReloadSize: CGSize?
  // TODO: change this to private
  public var floatingCells: Set<UIView> = []
  public var loading = false
  public var reloading = false

  public var tapGestureRecognizer = UITapGestureRecognizer()

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
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
        collectionView.yaal.contentOffset.updateWithCurrentState()
      }
    }
  }

  @objc func tap(gr: UITapGestureRecognizer) {
    for cell in visibleCells {
      if cell.point(inside: gr.location(in: cell), with: nil) {
        provider?.didTap(cell: cell, at: visibleCellToIndexMap[cell]!)
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
    if bounds.size != lastReloadSize {
      reloadData()
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
      loadCells()
    }
  }
  var activeFrame: CGRect {
    let extendedFrame = visibleFrame.insetBy(dx: -abs(scrollVelocity.x * 10).clamp(50, 400), dy: -abs(scrollVelocity.y * 10).clamp(50, 400))
    if let activeFrameSlop = activeFrameSlop {
      return CGRect(x: extendedFrame.origin.x + activeFrameSlop.left, y: extendedFrame.origin.y + activeFrameSlop.top, width: extendedFrame.width - activeFrameSlop.left - activeFrameSlop.right, height: extendedFrame.height - activeFrameSlop.top - activeFrameSlop.bottom)
    } else {
      return extendedFrame
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
    provider?.prepareForPresentation(collectionView: self)

    let indexes = visibleIndexesManager.visibleIndexes(for: activeFrame).union(floatingCells.map({ return visibleCellToIndexMap[$0]! }))
    let deletedIndexes = visibleIndexes.subtracting(indexes)
    let newIndexes = indexes.subtracting(visibleIndexes)
    for i in deletedIndexes {
      disappearCell(at: i)
    }
    for i in newIndexes {
      appearCell(at: i)
    }
    visibleIndexes = indexes

    for (index, view) in visibleCellToIndexMap.ts {
      if !floatingCells.contains(view) {
        provider?.update(view: view, at: index, frame: frames[index])
      }
    }
    loading = false
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (()->CGPoint)? = nil) {
    guard let provider = provider else { return }
    provider.willReload()
    reloading = true
    lastReloadSize = bounds.size
    provider.prepareLayout(maxSize: innerSize)
    provider.prepareForPresentation(collectionView: self)

    // ask the delegate for all cell's identifier & frames
    frames = []
    var newIdentifiersToIndexMap: DictionaryTwoWay<String, Int> = [:]
    var newVisibleCellToIndexMap: DictionaryTwoWay<UIView, Int> = [:]
    var unionFrame = CGRect.zero
    let itemCount = provider.numberOfItems
    let padding = provider.insets

    frames.reserveCapacity(itemCount)
    for index in 0..<itemCount {
      let frame = provider.frame(at: index)
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
      unionFrame = unionFrame.union(frame)
      frames.append(frame)
    }
    if padding.top != 0 || padding.left != 0 {
      for index in 0..<frames.count {
        frames[index].origin = frames[index].origin + CGPoint(x: padding.left, y: padding.top)
      }
    }
    visibleIndexesManager.reload(with: frames)

    let oldContentOffset = contentOffset
    contentSize = CGSize(width: max(minimumContentSize.width, unionFrame.size.width + padding.left + padding.right),
                         height: max(minimumContentSize.height, unionFrame.size.height + padding.top + padding.bottom))
    if let offset = contentOffsetAdjustFn?() {
      contentOffset = offset
    }
    let contentOffsetDiff = contentOffset - oldContentOffset

    provider.shift(delta: contentOffsetDiff)

    var newVisibleIndexes = visibleIndexesManager.visibleIndexes(for: activeFrame)
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
        provider.update(view: view, at: index, frame: frames[index])
      }
    }
    reloading = false
    hasReloaded = true
    provider.didReload()
  }

  fileprivate func disappearCell(at index: Int) {
    if let cell = visibleCellToIndexMap[index] {
      provider?.delete(view: cell, at: index, frame: frames[index])
      visibleCellToIndexMap.remove(index)
    }
  }
  fileprivate func appearCell(at index: Int) {
    guard let provider = provider else { return }
    let cell = provider.view(at: index)
    provider.update(view: cell, at: index)
    if visibleCellToIndexMap[cell] == nil {
      visibleCellToIndexMap[cell] = index
      insert(cell: cell)
      provider.insert(view: cell, at: index, frame: frames[index])
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

  override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    if supportOverflow {
      if super.point(inside: point, with: event) {
        return true
      }
      for cell in visibleCells {
        if cell.point(inside: cell.convert(point, from: self), with: event) {
          return true
        }
      }
      return false
    } else {
      return super.point(inside: point, with: event)
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
    let frame = frameForCell(at: index)!
    cell.yaal.center.animateTo(frame.center, stiffness: 300, damping: 25)
  }
}

extension CollectionView {
  public func indexForCell(at point: CGPoint) -> Int? {
    for (index, frame) in frames.enumerated() {
      if frame.contains(point) {
        return index
      }
    }
    return nil
  }

  public func frameForCell(at index: Int?) -> CGRect? {
    if let index = index {
      return frames.count > index ? frames[index] : nil
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
