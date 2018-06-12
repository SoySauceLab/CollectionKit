//
//  BasicProvider.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-18.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public func defaultSizeProvider<Data>(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
  return collectionSize
}

open class BasicProvider<Data, View: UIView>: ItemProviderType, CollectionReloadable {
  public typealias TapHandler = (View, Int, DataSource<Data>) -> Void

  public var identifier: String?
  public var dataSource: DataSource<Data> { didSet { setNeedsReload() } }
  public var viewSource: ViewSource<Data, View> { didSet { setNeedsReload() } }
  public var sizeSource: SizeSource<Data> = defaultSizeProvider { didSet { setNeedsReload() } }
  public var layout: Layout = FlowLayout() { didSet { setNeedsReload() } }
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
    self.dataSource = dataProvider
    self.viewSource = viewProvider
    self.layout = layout
    self.sizeSource = sizeProvider
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
    self.dataSource = dataProvider
    self.viewSource = ClosureViewSource(viewGenerator: viewGenerator, viewUpdater: viewUpdater)
    self.layout = layout
    self.sizeSource = sizeProvider
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
    self.dataSource = ArrayDataSource(data: data)
    self.viewSource = ClosureViewSource(viewGenerator: viewGenerator, viewUpdater: viewUpdater)
    self.layout = layout
    self.sizeSource = sizeProvider
    self.presenter = presenter
    self.willReloadHandler = willReloadHandler
    self.didReloadHandler = didReloadHandler
    self.tapHandler = tapHandler
    self.identifier = identifier
  }

  open var numberOfItems: Int {
    return dataSource.numberOfItems
  }
  open func view(at: Int) -> UIView {
    return viewSource.view(data: dataSource.data(at: at), index: at)
  }
  open func update(view: UIView, at: Int) {
    viewSource.update(view: view as! View, data: dataSource.data(at: at), index: at)
  }
  open func identifier(at: Int) -> String {
    return dataSource.identifier(at: at)
  }
  open func layout(collectionSize: CGSize) {
    layout.layout(context: BasicProviderLayoutContext(collectionSize: collectionSize,
                                                      dataProvider: dataSource,
                                                      sizeProvider: sizeSource))
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
    tapHandler?(view as! View, at, dataSource)
  }
  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || reloadable === dataSource
  }
}

struct BasicProviderLayoutContext<Data>: LayoutContext {
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
