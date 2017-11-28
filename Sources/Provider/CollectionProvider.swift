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

open class CollectionProvider<Data, View: UIView>: BaseCollectionProvider {
  public typealias DataProvider = CollectionDataProvider<Data>
  public typealias ViewProvider = CollectionViewProvider<Data, View>
  public typealias Layout = CollectionLayout<Data>
  public typealias SizeProvider = CollectionSizeProvider<Data>
  public typealias Presenter = CollectionPresenter

  public var dataProvider: DataProvider { didSet { setNeedsReload() } }
  public var viewProvider: ViewProvider { didSet { setNeedsReload() } }
  public var layout: Layout = FlowLayout<Data>() { didSet { setNeedsReload() } }
  public var sizeProvider: SizeProvider = defaultSizeProvider { didSet { setNeedsReload() } }
  public var presenter: Presenter? { didSet { setNeedsReload() } }

  public var willReloadHandler: (() -> Void)?
  public var didReloadHandler: (() -> Void)?
  public var tapHandler: ((View, Int, DataProvider) -> Void)?

  public init(dataProvider: DataProvider,
              viewProvider: ViewProvider) {
    self.dataProvider = dataProvider
    self.viewProvider = viewProvider
    super.init()
  }

  public convenience init(dataProvider: DataProvider,
                          viewGenerator: ((Data, Int) -> View)? = nil,
                          viewUpdater: @escaping (View, Data, Int) -> Void) {
    self.init(dataProvider: dataProvider,
              viewProvider: ClosureViewProvider(viewGenerator: viewGenerator,
                                                viewUpdater: viewUpdater))
  }

  public convenience init(data: [Data],
                          viewGenerator: ((Data, Int) -> View)? = nil,
                          viewUpdater: @escaping (View, Data, Int) -> Void) {
    self.init(dataProvider: ArrayDataProvider(data: data),
              viewProvider: ClosureViewProvider(viewGenerator: viewGenerator,
                                                viewUpdater: viewUpdater))
  }

  public convenience init(data: [Data],
                          viewProvider: ViewProvider) {
    self.init(dataProvider: ArrayDataProvider(data: data),
              viewProvider: viewProvider)
  }

  // MARK: - Override Methods
  open override var numberOfItems: Int {
    return dataProvider.numberOfItems
  }
  open override func view(at: Int) -> UIView {
    return viewProvider.view(data: dataProvider.data(at: at), index: at)
  }
  open override func update(view: UIView, at: Int) {
    viewProvider.update(view: view as! View, data: dataProvider.data(at: at), index: at)
  }
  open override func identifier(at: Int) -> String {
    return dataProvider.identifier(at: at)
  }
  open override func layout(collectionSize: CGSize) {
    layout.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
  }
  open override var contentSize: CGSize {
    return layout.contentSize
  }
  open override func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }
  open override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    return layout.visibleIndexes(activeFrame: activeFrame)
  }
  open override func presenter(at: Int) -> CollectionPresenter? {
    return presenter
  }
  open override func willReload() {
    super.willReload()
    willReloadHandler?()
  }
  open override func didReload() {
    super.didReload()
    didReloadHandler?()
  }
  open override func didTap(view: UIView, at: Int) {
    tapHandler?(view as! View, at, dataProvider)
  }
  open override func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || reloadable === dataProvider
  }
}
