//
//  CollectionKit.swift
//  CollectionKit
//
//  Created by YiLun Zhao on 2016-02-12.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit

open class CollectionView: UIScrollView {
  public var provider: AnyCollectionProvider = BaseCollectionProvider() { didSet { setNeedsReload() } }
  public var presenter: CollectionPresenter = CollectionPresenter() { didSet { setNeedsReload() } }

  public private(set) var reloadCount = 0
  public private(set) var needsReload = true
  public private(set) var loading = false
  public private(set) var reloading = false
  public private(set) var scrollVelocity: CGPoint = .zero
  public var hasReloaded: Bool { return reloadCount > 0 }

  public let tapGestureRecognizer = UITapGestureRecognizer()

  // visible identifiers for cells on screen
  public private(set) var visibleIndexes: [Int] = []
  public private(set) var visibleCells: [UIView] = []
  public private(set) var visibleIdentifiers: [String] = []

  var currentlyInsertedCells: Set<UIView>?
  var lastLoadBounds: CGRect?

  open override var contentOffset: CGPoint {
    didSet {
      scrollVelocity = contentOffset - oldValue
    }
  }

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

    tapGestureRecognizer.addTarget(self, action: #selector(tap(gesture:)))
    addGestureRecognizer(tapGestureRecognizer)
  }

  @objc func tap(gesture: UITapGestureRecognizer) {
    for (cell, index) in zip(visibleCells, visibleIndexes).reversed() {
      if cell.point(inside: gesture.location(in: cell), with: nil) {
        provider.didTap(view: cell, at: index)
        return
      }
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
    guard !loading && !reloading && hasReloaded else { return }
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
    guard !loading && !reloading && hasReloaded else { return }
    loading = true

    _loadCells(forceReload: false)

    for (cell, index) in zip(visibleCells, visibleIndexes) {
      let presenter = cell.currentCollectionPresenter ?? self.presenter
      presenter.update(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))
    }

    loading = false
  }

  // reload all frames. will automatically diff insertion & deletion
  public func reloadData(contentOffsetAdjustFn: (() -> CGPoint)? = nil) {
    guard !reloading else { return }
    provider.willReload()
    reloading = true

    provider.layout(collectionSize: innerSize)
    let oldContentOffset = contentOffset
    contentSize = provider.contentSize
    if let offset = contentOffsetAdjustFn?() {
      let scrollVelocity = self.scrollVelocity
      contentOffset = offset
      self.scrollVelocity = scrollVelocity
    }
    let contentOffsetDiff = contentOffset - oldContentOffset

    currentlyInsertedCells = Set<UIView>()
    _loadCells(forceReload: true)

    for (cell, index) in zip(visibleCells, visibleIndexes) {
      cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
      let presenter = cell.currentCollectionPresenter ?? self.presenter
      if !currentlyInsertedCells!.contains(cell) {
        // cell was on screen before reload, need to update the view.
        provider.update(view: cell, at: index)
        presenter.shift(collectionView: self, delta: contentOffsetDiff, view: cell,
                        at: index, frame: provider.frame(at: index))
      }
      presenter.update(collectionView: self, view: cell,
                       at: index, frame: provider.frame(at: index))
    }
    currentlyInsertedCells = nil

    needsReload = false
    reloadCount += 1
    reloading = false
    provider.didReload()
  }

  var identifierCache: [Int: String] = [:]

  private func _loadCells(forceReload: Bool) {
    lastLoadBounds = bounds

    let newIndexes = provider.visibleIndexes(visibleFrame: visibleFrame)

    // optimization: we assume that corresponding identifier for each index doesnt change unless forceReload is true.
    guard forceReload || newIndexes.last != visibleIndexes.last || newIndexes != visibleIndexes else {
      return
    }

    if forceReload {
      identifierCache.removeAll()
    }

    let newIdentifiers: [String] = newIndexes.map { index in
      if let identifier = identifierCache[index] {
        return identifier
      } else {
        let identifier = provider.identifier(at: index)
        identifierCache[index] = identifier
        return identifier
      }
    }

    var existingIdentifierToCellMap: [String: UIView] = [:]
    let newIdentifierSet = Set(newIdentifiers)

    // 1st pass, delete all removed cells
    for (index, identifier) in visibleIdentifiers.enumerated() {
      let cell = visibleCells[index]
      if !newIdentifierSet.contains(identifier) {
        (cell.currentCollectionPresenter ?? presenter).delete(collectionView: self, view: cell)
      } else {
        existingIdentifierToCellMap[identifier] = cell
      }
    }

    // 2nd pass, insert new views
    let newCells: [UIView] = zip(newIdentifiers, newIndexes).map { identifier, index in
      if let existingCell = existingIdentifierToCellMap[identifier] {
        return existingCell
      } else {
        let cell = _generateCell(index: index)
        currentlyInsertedCells?.insert(cell)
        return cell
      }
    }

    for (index, cell) in newCells.enumerated() where subviews.get(index) !== cell {
      insertSubview(cell, at: index)
    }

    visibleIndexes = newIndexes
    visibleIdentifiers = newIdentifiers
    visibleCells = newCells
  }

  private func _generateCell(index: Int) -> UIView {
    let cell = provider.view(at: index)
    let frame = provider.frame(at: index)
    cell.bounds.size = frame.bounds.size
    cell.center = frame.center
    cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
    let presenter = cell.currentCollectionPresenter ?? self.presenter
    presenter.insert(collectionView: self, view: cell, at: index, frame: provider.frame(at: index))
    return cell
  }
}

extension CollectionView {
  public func indexForCell(at point: CGPoint) -> Int? {
    for (index, cell) in zip(visibleIndexes, visibleCells) {
      if cell.point(inside: cell.convert(point, from: self), with: nil) {
        return index
      }
    }
    return nil
  }

  public func index(for cell: UIView) -> Int? {
    if let position = visibleCells.index(of: cell) {
      return visibleIndexes[position]
    }
    return nil
  }

  public func cell(at index: Int) -> UIView? {
    if let position = visibleIndexes.index(of: index) {
      return visibleCells[position]
    }
    return nil
  }
}
