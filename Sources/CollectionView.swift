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
  public var presenter: CollectionPresenter = CollectionPresenter()

  public private(set) var reloadCount = 0
  public private(set) var needsReload = true
  public private(set) var loading = false
  public private(set) var reloading = false
  public private(set) var screenDragLocation: CGPoint = .zero
  public private(set) var scrollVelocity: CGPoint = .zero
  public var hasReloaded: Bool { return reloadCount > 0 }

  public let tapGestureRecognizer = UITapGestureRecognizer()

  // all identifier provided by the provider
  var identifiers: [String] = []
  // index for all identifiers
  var identifierToIndex: [String: Int] = [:]
  // visible identifiers for cells on screen
  var visibleIdentifiers: [String] = []
  // view for identifiers that are on screen
  var identifierToView: [String: UIView] = [:]

  var currentlyInsertedIdentifiers: Set<String>?

  var lastLoadBounds: CGRect?

  public var activeFrameInset: UIEdgeInsets? {
    didSet {
      if !reloading && activeFrameInset != oldValue {
        loadCells()
      }
    }
  }
  open override var contentOffset: CGPoint {
    didSet {
      scrollVelocity = contentOffset - oldValue
    }
  }
  var activeFrame: CGRect {
    return UIEdgeInsetsInsetRect(visibleFrame, activeFrameInset ?? .zero)
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

    panGestureRecognizer.addTarget(self, action: #selector(pan(gesture:)))
  }

  @objc func tap(gesture: UITapGestureRecognizer) {
    for identifier in visibleIdentifiers.reversed() {
      let cell = identifierToView[identifier]!
      let index = identifierToIndex[identifier]!
      if cell.point(inside: gesture.location(in: cell), with: nil) {
        provider.didTap(view: cell, at: index)
        return
      }
    }
  }

  func pan(gesture: UIPanGestureRecognizer) {
    screenDragLocation = absoluteLocation(for: gesture.location(in: self))
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

    _loadCells()

    for identifier in visibleIdentifiers {
      let cell = identifierToView[identifier]!
      let index = identifierToIndex[identifier]!
      let presenter = cell.currentCollectionPresenter ?? self.presenter
      presenter.update(collectionView:self, view: cell, at: index, frame: provider.frame(at: index))
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

    currentlyInsertedIdentifiers = Set<String>()
    _reloadIdentifiers()
    _loadCells()

    for identifier in visibleIdentifiers {
      let cell = identifierToView[identifier]!
      let index = identifierToIndex[identifier]!
      cell.currentCollectionPresenter = cell.collectionPresenter ?? provider.presenter(at: index)
      let presenter = cell.currentCollectionPresenter ?? self.presenter
      if !currentlyInsertedIdentifiers!.contains(identifier) {
        // cell was on screen before reload, need to update the view.
        provider.update(view: cell, at: index)
        presenter.shift(collectionView: self, delta: contentOffsetDiff, view: cell,
                        at: index, frame: provider.frame(at: index))
      }
      presenter.update(collectionView:self, view: cell,
                       at: index, frame: provider.frame(at: index))
    }
    currentlyInsertedIdentifiers = nil

    needsReload = false
    reloadCount += 1
    reloading = false
    provider.didReload()
  }

  private func _reloadIdentifiers() {
    var newIdentifiers: [String] = []
    var newIdentifierToIndex: [String: Int] = [:]
    for index in 0..<provider.numberOfItems {
      var identifier = provider.identifier(at: index)
      if newIdentifierToIndex[identifier] != nil {
        // Duplicate Identifier. will add a counter suffix to the identifier.
        var i = 2
        let originalIdentifier = identifier
        repeat {
          identifier = originalIdentifier + "\(i)"
          i += 1
        } while newIdentifierToIndex[identifier] != nil
      }
      newIdentifiers.append(identifier)
      newIdentifierToIndex[identifier] = index
    }
    identifiers = newIdentifiers
    identifierToIndex = newIdentifierToIndex
  }

  private func _loadCells() {
    lastLoadBounds = bounds

    let indexes = provider.visibleIndexes(activeFrame: activeFrame)
    let oldIdentifiers = visibleIdentifiers
    let newIdentifiers = indexes.map({ identifiers[$0] })

    let oldIdentifierSet = Set(oldIdentifiers)
    let newIdentifierSet = Set(newIdentifiers)

    // 1st pass, delete all removed cells
    for identifier in oldIdentifiers {
      if !newIdentifierSet.contains(identifier) {
        let cell = identifierToView.removeValue(forKey: identifier)!
        (cell.currentCollectionPresenter ?? presenter).delete(collectionView: self, view: cell)
      }
    }

    // 2nd pass, insert new views
    for (index, identifier) in newIdentifiers.enumerated() {
      let cell: UIView
      if !oldIdentifierSet.contains(identifier) {
        currentlyInsertedIdentifiers?.insert(identifier)
        cell = _generateCell(identifier: identifier)
        identifierToView[identifier] = cell
      } else {
        cell = identifierToView[identifier]!
      }
      insertSubview(cell, at: index)
    }

    self.visibleIdentifiers = newIdentifiers
  }

  private func _generateCell(identifier: String) -> UIView {
    let index = identifierToIndex[identifier]!
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
  public var visibleCells: [UIView] {
    return visibleIdentifiers.map { identifierToView[$0]! }
  }

  public func indexForCell(at point: CGPoint) -> Int? {
    for (index, cell) in visibleCells.enumerated() {
      if cell.point(inside: cell.convert(point, from: self), with: nil) {
        return identifierToIndex[visibleIdentifiers[index]]
      }
    }
    return nil
  }

  public func index(for cell: UIView) -> Int? {
    if let index = visibleCells.index(of: cell) {
      return identifierToIndex[visibleIdentifiers[index]]
    }
    return nil
  }

  public func cell(at index: Int) -> UIView? {
    if let identifier = visibleIdentifiers.lazy.filter({ self.identifierToIndex[$0] == index }).first {
      return identifierToView[identifier]
    }
    return nil
  }
}
