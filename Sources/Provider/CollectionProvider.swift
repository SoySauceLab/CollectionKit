//
//  CollectionProvider.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-18.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public func defaultSizeProvider<Data>(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
  return collectionSize
}

@available(*, deprecated, message: "Use DataProvider instead")
public typealias CollectionDataProvider = DataSource

@available(*, deprecated, message: "Use ViewProvider instead")
public typealias CollectionViewProvider = ViewSource

@available(*, deprecated, message: "Use SizeProvider instead")
public typealias CollectionSizeProvider = SizeSource

open class CollectionProvider<Data, View: UIView>: FlatProviderType, CollectionReloadable {
  public typealias TapHandler = (View, Int, DataSource<Data>) -> Void

  public var identifier: String?
  public var dataProvider: DataSource<Data> { didSet { setNeedsReload() } }
  public var viewProvider: ViewSource<Data, View> { didSet { setNeedsReload() } }
  public var layout: Layout = FlowLayout() { didSet { setNeedsReload() } }
  public var sizeProvider: SizeSource<Data> = defaultSizeProvider { didSet { setNeedsReload() } }
  public var presenter: Presenter? { didSet { setNeedsReload() } }

  public var willReloadHandler: (() -> Void)?
  public var didReloadHandler: (() -> Void)?
  public var tapHandler: TapHandler?

  public init(identifier: String? = nil,
              dataProvider: DataSource<Data>,
              viewProvider: ViewSource<Data, View>,
              layout: Layout = FlowLayout(),
              sizeProvider: @escaping SizeSource<Data> = defaultSizeProvider,
              presenter: Presenter? = nil,
              willReloadHandler: (() -> Void)? = nil,
              didReloadHandler: (() -> Void)? = nil,
              tapHandler: TapHandler? = nil) {
    self.dataProvider = dataProvider
    self.viewProvider = viewProvider
    self.layout = layout
    self.sizeProvider = sizeProvider
    self.presenter = presenter
    self.willReloadHandler = willReloadHandler
    self.didReloadHandler = didReloadHandler
    self.tapHandler = tapHandler
    self.identifier = identifier
  }

  public init(identifier: String? = nil,
              dataProvider: DataSource<Data>,
              viewGenerator: ((Data, Int) -> View)? = nil,
              viewUpdater: @escaping (View, Data, Int) -> Void,
              layout: Layout = FlowLayout(),
              sizeProvider: @escaping SizeSource<Data> = defaultSizeProvider,
              presenter: Presenter? = nil,
              willReloadHandler: (() -> Void)? = nil,
              didReloadHandler: (() -> Void)? = nil,
              tapHandler: TapHandler? = nil) {
    self.dataProvider = dataProvider
    self.viewProvider = ClosureViewProvider(viewGenerator: viewGenerator, viewUpdater: viewUpdater)
    self.layout = layout
    self.sizeProvider = sizeProvider
    self.presenter = presenter
    self.willReloadHandler = willReloadHandler
    self.didReloadHandler = didReloadHandler
    self.tapHandler = tapHandler
    self.identifier = identifier
  }

  public init(identifier: String? = nil,
              data: [Data],
              viewGenerator: ((Data, Int) -> View)? = nil,
              viewUpdater: @escaping (View, Data, Int) -> Void,
              layout: Layout = FlowLayout(),
              sizeProvider: @escaping SizeSource<Data> = defaultSizeProvider,
              presenter: Presenter? = nil,
              willReloadHandler: (() -> Void)? = nil,
              didReloadHandler: (() -> Void)? = nil,
              tapHandler: TapHandler? = nil) {
    self.dataProvider = ArrayDataProvider(data: data)
    self.viewProvider = ClosureViewProvider(viewGenerator: viewGenerator, viewUpdater: viewUpdater)
    self.layout = layout
    self.sizeProvider = sizeProvider
    self.presenter = presenter
    self.willReloadHandler = willReloadHandler
    self.didReloadHandler = didReloadHandler
    self.tapHandler = tapHandler
    self.identifier = identifier
  }

  open var numberOfItems: Int {
    return dataProvider.numberOfItems
  }
  open func view(at: Int) -> UIView {
    return viewProvider.view(data: dataProvider.data(at: at), index: at)
  }
  open func update(view: UIView, at: Int) {
    viewProvider.update(view: view as! View, data: dataProvider.data(at: at), index: at)
  }
  open func identifier(at: Int) -> String {
    return dataProvider.identifier(at: at)
  }
  open func layout(collectionSize: CGSize) {
    layout.layout(context: CollectionProviderLayoutContext(collectionSize: collectionSize,
                                                           dataProvider: dataProvider,
                                                           sizeProvider: sizeProvider))
  }
  open var contentSize: CGSize {
    return layout.contentSize
  }
  open func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }
  open func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return layout.visibleIndexes(visibleFrame: visibleFrame)
  }
  open func presenter(at: Int) -> Presenter? {
    return presenter
  }
  open func willReload() {
    willReloadHandler?()
  }
  open func didReload() {
    didReloadHandler?()
  }
  open func didTap(view: UIView, at: Int) {
    tapHandler?(view as! View, at, dataProvider)
  }
  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || reloadable === dataProvider
  }
}

struct CollectionProviderLayoutContext<Data>: LayoutContext {
  var collectionSize: CGSize
  var dataProvider: DataSource<Data>
  var sizeProvider: SizeSource<Data>

  var numberOfItems: Int {
    return dataProvider.numberOfItems
  }
  func data(at: Int) -> Any {
    return dataProvider.data(at: at)
  }
  func identifier(at: Int) -> String {
    return dataProvider.identifier(at: at)
  }
  func size(at: Int, collectionSize: CGSize) -> CGSize {
    return sizeProvider(at, dataProvider.data(at: at), collectionSize)
  }
}
