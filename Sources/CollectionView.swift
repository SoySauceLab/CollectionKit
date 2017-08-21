//
//  CollectionKit.swift
//  CollectionKit
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import Diff
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
  public private(set) var visibleIndexes: [Int] = []
  public var visibleCells: [HashableTuple<UIView, Int>] = []
  var identifiers: [HashableTuple<String, (UIView?, Int)>] = []

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
    for cellInfo in visibleCells {
      let (cell, index) = (cellInfo.source, cellInfo.info)
      if cell.point(inside: gr.location(in: cell), with: nil) {
        provider.didTap(view: cell, at: index)
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
    let visibleCellsCopy = visibleCells
    if let deleteEndIndex = visibleIndexes.index(of: indexes[0]) {
      for i in 0..<deleteEndIndex {
        let cell = visibleCellsCopy[i].source
        let index = visibleCellsCopy[i].info
        if bounds.intersects(cell.frame) {
          // TODO(luke): Handle this case
          // Dont remove cell if it is still on screen. this is probably because the presenter is doing some animation with the cell
          // which resulted the cell being at a different position. We will remove this cell later.
        } else {
          disappearCell(info: (cell, index))
          identifiers[index].info = (nil, index)
          visibleCells.remove(at: i)
        }
      }
    }

    if let lastIndex = indexes.index(of: visibleIndexes.last!) {
      for i in (lastIndex + 1)..<indexes.endIndex {
        let newCellIndex = indexes[i]
        let newCell = appearCell(at: newCellIndex)
        identifiers[newCellIndex].info = (newCell, newCellIndex)
        visibleCells.insert(HashableTuple(source: newCell, info: newCellIndex), at: i)
        self.insertSubview(newCell, at: i)
      }
    }

    visibleIndexes = indexes
    
    if !needsReload {
      for cellInfo in visibleCells {
        let (cell, index) = (cellInfo.source, cellInfo.info)
        (cell.currentCollectionPresenter ?? presenter).update(collectionView:self, view: cell, at: index, frame: provider.frame(at: index))
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
    var newIdentifiers: [HashableTuple<String, (UIView?, Int)>] = []
    var newIdentifiersSet: Set<String> = []
    let itemCount = provider.numberOfItems

    for index in 0..<itemCount {
      let identifier = provider.identifier(at: index)
      if newIdentifiersSet.contains(identifier) {
        // print("[CollectionView] Duplicate Identifier: \(identifier)")
        var i = 2
        var newIdentifier = ""
        repeat {
          newIdentifier = identifier + "\(i)"
          i += 1
        } while newIdentifiersSet.contains(newIdentifier)
        newIdentifiersSet.insert(newIdentifier)
        newIdentifiers.append(HashableTuple(source: newIdentifier, info: (nil, index)))
      } else {
        newIdentifiersSet.insert(identifier)
        newIdentifiers.append(HashableTuple(source: identifier, info: (nil, index)))
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
    let newVisibleIdentifiers = newVisibleIndexes.map { index in
      return newIdentifiers[index]
    }
    let oldVisibleIndexes = visibleIndexes
    let oldVisibleIdentifiers = oldVisibleIndexes.map { index in
      return identifiers[index]
    }

    var oldVisibleIdentifiersCopy = oldVisibleIdentifiers
    let patch = extendedPatch(from: oldVisibleIdentifiers, to: newVisibleIdentifiers)
    patch.forEach { element in
      switch element {
      case let .insertion(index, e):
        oldVisibleIdentifiersCopy.insert(e, at: index)
        let appearIndex = e.info.1
        let newCell = appearCell(at: appearIndex)
        newIdentifiers[appearIndex].info = (newCell, appearIndex)
        visibleCells.insert(HashableTuple(source: newCell, info: appearIndex), at: index)
        self.insertSubview(newCell, at: index)
      case .deletion(let index):
        let toRemove = oldVisibleIdentifiersCopy.remove(at: index)
        let info = toRemove.info
        disappearCell(info: info)
        visibleCells.remove(at: index)
      case let .move(from, to):
        let toMove = oldVisibleIdentifiersCopy.remove(at: from)
        oldVisibleIdentifiersCopy.insert(toMove, at: to)
        let newInfo = newVisibleIdentifiers[to].info
        if let cell = toMove.info.0 {
          let toIndex = newInfo.1
          provider.update(view: cell, at: toIndex)
          cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: toIndex)
          (cell.currentCollectionPresenter ?? presenter).shift(collectionView: self, delta: contentOffsetDiff, view: cell, at: toIndex, frame: provider.frame(at: toIndex))
          newIdentifiers[toIndex].info = (cell, toIndex)
          visibleCells.remove(at: from)
          visibleCells.insert(HashableTuple(source: cell, info: toIndex), at: to)
          cell.removeFromSuperview()
          self.insertSubview(cell, at: to)
        }
      }
    }

    // TODO(simon): Fix this, this is not correct.
    // Even if there is no difference based on identifier, update cell as well.
    if patch.count == 0 {
      oldVisibleIdentifiers.forEach { info in
        if let cell = info.info.0 {
          let index = info.info.1
          provider.update(view: cell, at: index)
          cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
          (cell.currentCollectionPresenter ?? presenter).shift(collectionView: self, delta: contentOffsetDiff, view: cell, at: index, frame: provider.frame(at: index))
          newIdentifiers[index].info = (cell, index)
        }
      }
    }
    
    identifiers = newIdentifiers
    visibleIndexes = newVisibleIndexes
    
    for cellInfo in visibleCells {
      let (cell, index) = (cellInfo.source, cellInfo.info)
      (cell.currentCollectionPresenter ?? presenter).update(collectionView:self, view: cell, at: index, frame: provider.frame(at: index))
    }
    
    needsReload = false
    reloadCount += 1
    reloading = false
    provider.didReload()
  }

  fileprivate func disappearCell(info: (UIView?, Int)) {
    if let cell = info.0 {
      (cell.currentCollectionPresenter ?? presenter).delete(collectionView: self, view: cell, at: info.1)
    }
  }

  fileprivate func appearCell(at index: Int) -> UIView {
    let cell = provider.view(at: index)
    let frame = provider.frame(at: index)
    cell.bounds.size = frame.bounds.size
    cell.center = frame.center
    provider.update(view: cell, at: index)
    cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
    (cell.currentCollectionPresenter ?? presenter).insert(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))
    return cell
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
}
