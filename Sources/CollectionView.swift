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
  public var provider: AnyCollectionProvider = BaseCollectionProvider() { didSet { setNeedsReload() } }
  public var presenter: CollectionPresenter = CollectionPresenter()

  public private(set) var reloadCount = 0
  public private(set) var needsReload = true
  public private(set) var loading = false
  public private(set) var reloading = false
  public private(set) var screenDragLocation: CGPoint = .zero
  public private(set) var scrollVelocity: CGPoint = .zero
  public var hasReloaded: Bool { return reloadCount > 0 }

  public let tapGestureRecognizer = UITapGestureRecognizer()
  public private(set) var visibleIndexes: Set<Int> = []
  public var visibleCells: [UIView] { return Array(visibleCellToIndexMap.st.keys) }

  public var activeFrameInset: UIEdgeInsets? {
    didSet {
      if !reloading && activeFrameInset != oldValue {
        loadCells()
      }
    }
  }
  open override var contentOffset: CGPoint{
    didSet{
      scrollVelocity = contentOffset - oldValue
    }
  }
  var activeFrame: CGRect {
    return UIEdgeInsetsInsetRect(visibleFrame, activeFrameInset ?? .zero)
  }
  var visibleCellToIndexMap: DictionaryTwoWay<UIView, Int> = [:]
  var identifiersToIndexMap: DictionaryTwoWay<String, Int> = [:]
  var lastLoadBounds: CGRect?

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

    panGestureRecognizer.addTarget(self, action: #selector(pan(gr:)))
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
    if needsReload {
      reloadData()
    } else if bounds.size != lastLoadBounds?.size {
      invalidateLayout()
    } else if bounds != lastLoadBounds {
      loadCells()
    }
  }

  public func setNeedsReload() {
    needsReload = true
    setNeedsLayout()
  }

  public func invalidateLayout() {
    if loading || reloading || !hasReloaded { return }
    provider.layout(collectionSize: innerSize)
    contentSize = provider.contentSize
    loadCells()
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

    var indexes = provider.visibleIndexes(activeFrame: activeFrame)
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
        (view.currentCollectionPresenter ?? presenter).update(collectionView:self, view: view, at: index, frame: provider.frame(at: index))
      }
    }
    loading = false
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    provider.willReload()
    reloading = true
    lastLoadBounds = bounds
    provider.layout(collectionSize: innerSize)

    // ask the delegate for all cell's identifier & frames
    var newIdentifiersToIndexMap: DictionaryTwoWay<String, Int> = [:]
    var newVisibleCellToIndexMap: DictionaryTwoWay<UIView, Int> = [:]
    let itemCount = provider.numberOfItems

    for index in 0..<itemCount {
      let identifier = provider.identifier(at: index)
      if newIdentifiersToIndexMap[identifier] != nil {
        // print("[CollectionView] Duplicate Identifier: \(identifier)")
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

    let newVisibleIndexes = provider.visibleIndexes(activeFrame: activeFrame)

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

      newVisibleCellToIndexMap[newIndex] = cell
      provider.update(view: cell, at: newIndex)
      cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: newIndex)
      (cell.currentCollectionPresenter ?? presenter).shift(collectionView: self, delta: contentOffsetDiff, view: cell, at: newIndex, frame: provider.frame(at: newIndex))
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
      (view.currentCollectionPresenter ?? presenter).update(collectionView:self, view: view, at: index, frame: provider.frame(at: index))
    }

    needsReload = false
    reloadCount += 1
    reloading = false
    provider.didReload()
  }

  fileprivate func disappearCell(at index: Int) {
    if let cell = visibleCellToIndexMap[index] {
      (cell.currentCollectionPresenter ?? presenter).delete(collectionView: self, view: cell, at: index)
      visibleCellToIndexMap.remove(index)
    }
  }

  fileprivate func appearCell(at index: Int) {
    let cell = provider.view(at: index)
    let frame = provider.frame(at: index)
    cell.bounds.size = frame.bounds.size
    cell.center = frame.center
    provider.update(view: cell, at: index)
    cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
    if visibleCellToIndexMap[cell] == nil {
      visibleCellToIndexMap[cell] = index
      insert(cell: cell)
      (cell.currentCollectionPresenter ?? presenter).insert(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))
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
        addSubview(cell)
      } else {
        insertSubview(cell, belowSubview: visibleCellToIndexMap[currentMin]!)
      }
    } else {
      addSubview(cell)
    }
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
