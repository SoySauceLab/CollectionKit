//
//  CollectionProvider.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-18.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionProvider<Data, View>: AnyCollectionProvider where View: UIView
{
  public typealias DataProvider = CollectionDataProvider<Data>
  public typealias ViewProvider = CollectionViewProvider<Data, View>
  public typealias Layout = CollectionLayout<Data>
  public typealias SizeProvider = CollectionSizeProvider<Data>
  public typealias Responder = CollectionResponder<Data>
  public typealias Presenter = CollectionPresenter
  
  public var dataProvider: DataProvider { didSet { setNeedsReload() } }
  public var viewProvider: ViewProvider { didSet { setNeedsReload() } }
  public var layout: Layout { didSet { setNeedsReload() } }
  public var sizeProvider: SizeProvider { didSet { setNeedsReload() } }
  public var responder: Responder { didSet { setNeedsReload() } }
  public var presenter: Presenter? { didSet { setNeedsReload() } }

  public init(dataProvider: DataProvider,
              viewProvider: ViewProvider,
              layout: Layout = FlowLayout<Data>(),
              sizeProvider: SizeProvider = SizeProvider(),
              responder: Responder = Responder(),
              presenter: Presenter? = nil) {
    self.dataProvider = dataProvider
    self.viewProvider = viewProvider
    self.layout = layout
    self.sizeProvider = sizeProvider
    self.responder = responder
    self.presenter = presenter
  }
  
  open var numberOfItems: Int {
    return dataProvider.numberOfItems
  }
  open func view(at: Int) -> UIView {
    let view = viewProvider.view(at: at)
    if let presenter = presenter, view.collectionPresenter == nil {
      view.collectionPresenter = presenter
    }
    return view
  }
  open func update(view: UIView, at: Int) {
    viewProvider.update(view: view as! View, with: dataProvider.data(at: at), at: at)
  }
  open func identifier(at: Int) -> String {
    return dataProvider.identifier(at: at)
  }

  open func layout(collectionSize: CGSize) {
    layout._layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
  }
  open var contentSize: CGSize {
    return layout.contentSize
  }
  open func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }
  open func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    return layout.visibleIndexes(activeFrame: activeFrame)
  }

  open func willReload() {
    responder.willReload()
  }
  open func didReload() {
    responder.didReload()
  }
  open func willDrag(view: UIView, at:Int) -> Bool {
    return responder.willDrag(view: view, at: at, dataProvider: dataProvider)
  }
  open func didDrag(view: UIView, at:Int) {
    responder.didDrag(view: view, at: at, dataProvider: dataProvider)
  }
  open func moveItem(at: Int, to: Int) -> Bool {
    return responder.moveItem(at: at, to: to, dataProvider: dataProvider)
  }
  open func didTap(view: UIView, at: Int) {
    responder.didTap(view: view, at: at, dataProvider: dataProvider)
  }
  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || reloadable === dataProvider || reloadable === responder
  }
}

open class BaseCollectionProvider: AnyCollectionProvider {

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
}
