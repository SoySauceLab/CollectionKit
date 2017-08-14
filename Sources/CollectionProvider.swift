//
//  CollectionProvider.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-18.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

func defaultSizeProvider<Data>(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
  return collectionSize
}

open class CollectionProvider<Data, View: UIView>: BaseCollectionProvider
{
  public typealias DataProvider = CollectionDataProvider<Data>
  public typealias ViewProvider = CollectionViewProvider<Data, View>
  public typealias Layout = CollectionLayout<Data>
  public typealias SizeProvider = CollectionSizeProvider<Data>
  public typealias Presenter = CollectionPresenter
  
  public var dataProvider: DataProvider { didSet { setNeedsReload() } }
  public var viewProvider: ViewProvider { didSet { setNeedsReload() } }
  public var layout: Layout { didSet { setNeedsReload() } }
  public var sizeProvider: SizeProvider { didSet { setNeedsReload() } }
  public var presenter: Presenter? { didSet { setNeedsReload() } }

  public var willReloadHandler: (() -> Void)?
  public var didReloadHandler: (() -> Void)?
  public var willDragHandler: ((UIView, Int, DataProvider) -> Bool)?
  public var didDragHandler: ((UIView, Int, DataProvider) -> Void)?
  public var moveHandler: ((Int, Int, DataProvider) -> Bool)?
  public var tapHandler: ((UIView, Int, DataProvider) -> Void)?

  public init(identifier: String? = nil,
              dataProvider: DataProvider,
              viewProvider: ViewProvider,
              layout: Layout = FlowLayout<Data>(),
              sizeProvider: @escaping SizeProvider = defaultSizeProvider,
              presenter: Presenter? = nil,
              willReloadHandler: (() -> Void)? = nil,
              didReloadHandler: (() -> Void)? = nil,
              willDragHandler: ((UIView, Int, DataProvider) -> Bool)? = nil,
              didDragHandler: ((UIView, Int, DataProvider) -> Void)? = nil,
              moveHandler: ((Int, Int, DataProvider) -> Bool)? = nil,
              tapHandler: ((UIView, Int, DataProvider) -> Void)? = nil) {
    self.dataProvider = dataProvider
    self.viewProvider = viewProvider
    self.layout = layout
    self.sizeProvider = sizeProvider
    self.presenter = presenter
    self.willReloadHandler = willReloadHandler
    self.didReloadHandler = didReloadHandler
    self.willDragHandler = willDragHandler
    self.didDragHandler = didDragHandler
    self.moveHandler = moveHandler
    self.tapHandler = tapHandler
    super.init()
    self.identifier = identifier
  }
  
  open override var numberOfItems: Int {
    return dataProvider.numberOfItems
  }
  open override func view(at: Int) -> UIView {
    return viewProvider.view(at: at)
  }
  open override func update(view: UIView, at: Int) {
    viewProvider.update(view: view as! View, with: dataProvider.data(at: at), at: at)
  }
  open override func identifier(at: Int) -> String {
    return dataProvider.identifier(at: at)
  }

  open override func layout(collectionSize: CGSize) {
    layout._layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
  }
  open override var contentSize: CGSize {
    return layout.contentSize
  }
  open override func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }
  open override func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    return layout.visibleIndexes(activeFrame: activeFrame)
  }

  open override func presenter(at: Int) -> CollectionPresenter? {
    return presenter
  }

  open override func willReload() {
    willReloadHandler?()
  }
  open override func didReload() {
    didReloadHandler?()
  }
  open override func willDrag(view: UIView, at:Int) -> Bool {
    return willDragHandler?(view, at, dataProvider) ?? false
  }
  open override func didDrag(view: UIView, at:Int) {
    didDragHandler?(view, at, dataProvider)
  }
  open override func moveItem(at: Int, to: Int) -> Bool {
    return moveHandler?(at, to, dataProvider) ?? false
  }
  open override func didTap(view: UIView, at: Int) {
    tapHandler?(view, at, dataProvider)
  }
  open override func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || reloadable === dataProvider
  }
}

open class BaseCollectionProvider: AnyCollectionProvider {
  public var identifier: String?

  public init() {}
  
  open var numberOfItems: Int {
    return 0
  }
  open func view(at: Int) -> UIView {
    return UIView()
  }
  open func update(view: UIView, at: Int) {}
  open func identifier(at: Int) -> String {
    return "\(at)"
  }
  
  open var contentSize: CGSize {
    return .zero
  }
  open func layout(collectionSize: CGSize) {}
  open func frame(at: Int) -> CGRect {
    return .zero
  }
  open func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    return Set<Int>()
  }

  open func presenter(at: Int) -> CollectionPresenter? {
    return nil
  }

  open func willReload() {}
  open func didReload() {}
  open func willDrag(view: UIView, at:Int) -> Bool {
    return false
  }
  open func didDrag(view: UIView, at:Int) {}
  open func moveItem(at: Int, to: Int) -> Bool {
    return false
  }
  open func didTap(view: UIView, at: Int) {}

  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self
  }
}
