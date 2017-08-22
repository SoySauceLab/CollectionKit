//
//  CollectionKit.swift
//  CollectionKit
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import Diff
import UIKit

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
  var identifiers: [String] = []
  var visibleIdentifiers: [String] = []
  var identifierToView: [String: UIView] = [:]
  var identifierToIndex: [String: Int] = [:]

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
    for identifier in visibleIdentifiers {
      let cell = identifierToView[identifier]!
      let index = identifierToIndex[identifier]!
      if cell.point(inside: gr.location(in: cell), with: nil) {
        provider.didTap(view: cell, at: index)
      }
    }
  }

  func pan(gr: UIPanGestureRecognizer) {
    screenDragLocation = absoluteLocation(for: gr.location(in: self))
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

    _loadCells()

    for identifier in visibleIdentifiers {
      let cell = identifierToView[identifier]!
      let index = identifierToIndex[identifier]!
      (cell.currentCollectionPresenter ?? presenter).update(collectionView:self, view: cell, at: index, frame: provider.frame(at: index))
    }

    loading = false
  }

  private func _loadCells() {
    lastLoadBounds = bounds

    let indexes = provider.visibleIndexes(activeFrame: activeFrame)

    var tempVisibleIdentifiers = visibleIdentifiers
    let newVisibleIdentifiers = indexes.map { identifiers[$0] }
    //    let diff = visibleIdentifiers.extendedDiff(newVisibleIdentifiers)
    //    diff.forEach { element in
    //      switch element {
    //      case let .insert(index):
    //        let identifier = newVisibleIdentifiers[index]
    //        let cell = appearCell(identifier: identifier)
    //        visi
    //        //insertSubview(cell, at: viewIndex)
    //      case let .delete(index):
    //        let identifier = visibleIdentifiers[index]
    //        disappearCell(identifier: identifier)
    //      case let .move(from, to):
    //        let toMoveIdentifier = visibleIdentifiers[from]
    //        let cell = identifierToView[toMoveIdentifier]
    //        insertSubview(cell, at: toViewIndex)
    //      }
    //    }

    let patch = extendedPatch(from: visibleIdentifiers, to: newVisibleIdentifiers)
    patch.forEach { element in
      switch element {
      case let .insertion(viewIndex, identifier):
        let previousCell = viewIndex > 0 ? identifierToView[tempVisibleIdentifiers[viewIndex - 1]] : nil
        tempVisibleIdentifiers.insert(identifier, at: viewIndex)
        let cell = appearCell(identifier: identifier)
        if let previousCell = previousCell {
          let previousCellIndex = subviews.index(of: previousCell)!
          insertSubview(cell, at: previousCellIndex + 1)
        } else {
          insertSubview(cell, at: 0)
        }
      case let .deletion(viewIndex):
        let identifier = tempVisibleIdentifiers.remove(at: viewIndex)
        disappearCell(identifier: identifier)
      case let .move(fromViewIndex, toViewIndex):
        let previousCell = toViewIndex > 0 ? identifierToView[tempVisibleIdentifiers[toViewIndex - 1]] : nil
        let toMove = tempVisibleIdentifiers.remove(at: fromViewIndex)
        tempVisibleIdentifiers.insert(toMove, at: toViewIndex)
        let cell = identifierToView[toMove]!
        if let previousCell = previousCell {
          let previousCellIndex = subviews.index(of: previousCell)!
          insertSubview(cell, at: previousCellIndex + 1)
        } else {
          insertSubview(cell, at: 0)
        }
      }
    }

    visibleIndexes = indexes
    visibleIdentifiers = newVisibleIdentifiers
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    provider.willReload()
    reloading = true
    provider.layout(collectionSize: innerSize)

    // ask the delegate for all cell's identifier & frames
    var newIdentifiers: [String] = []
    var newIdentifierToIndex: [String: Int] = [:]
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
        newIdentifiers.append(newIdentifier)
        newIdentifierToIndex[newIdentifier] = index
      } else {
        newIdentifiersSet.insert(identifier)
        newIdentifiers.append(identifier)
        newIdentifierToIndex[identifier] = index
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

    identifiers = newIdentifiers
    identifierToIndex = newIdentifierToIndex

    _loadCells()

    for identifier in visibleIdentifiers {
      let cell = identifierToView[identifier]!
      let index = identifierToIndex[identifier]!
      provider.update(view: cell, at: index)
      cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
      (cell.currentCollectionPresenter ?? presenter).shift(collectionView: self, delta: contentOffsetDiff, view: cell, at: index, frame: provider.frame(at: index))
      (cell.currentCollectionPresenter ?? presenter).update(collectionView:self, view: cell, at: index, frame: provider.frame(at: index))
    }

    needsReload = false
    reloadCount += 1
    reloading = false
    provider.didReload()
  }

  fileprivate func disappearCell(identifier: String) {
    let cell = identifierToView[identifier]!
    let index = identifierToIndex[identifier]!
    identifierToView[identifier] = nil
    (cell.currentCollectionPresenter ?? presenter).delete(collectionView: self, view: cell, at: index)
  }

  fileprivate func appearCell(identifier: String) -> UIView {
    let index = identifierToIndex[identifier]!
    let cell = provider.view(at: index)
    let frame = provider.frame(at: index)
    cell.bounds.size = frame.bounds.size
    cell.center = frame.center
    provider.update(view: cell, at: index)
    cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
    (cell.currentCollectionPresenter ?? presenter).insert(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))

    identifierToView[identifier] = cell
    return cell
  }
}

extension CollectionView {
  public var visibleCells: [UIView] {
    return visibleIdentifiers.map { identifierToView[$0]! }
  }
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
