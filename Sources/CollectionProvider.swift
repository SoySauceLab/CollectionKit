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
  public var dataProvider: CollectionDataProvider<Data>
  public var viewProvider: CollectionViewProvider<Data, View>
  public var layout: CollectionLayout<Data>
  public var sizeProvider: CollectionSizeProvider<Data>
  public var responder: CollectionResponder
  public var presenter: CollectionPresenter

  public init(dataProvider: CollectionDataProvider<Data>,
              viewProvider: CollectionViewProvider<Data, View>,
              layout: CollectionLayout<Data> = FlowLayout<Data>(),
              sizeProvider: CollectionSizeProvider<Data> = CollectionSizeProvider<Data>(),
              responder: CollectionResponder = CollectionResponder(),
              presenter: CollectionPresenter = CollectionPresenter()) {
    self.dataProvider = dataProvider
    self.viewProvider = viewProvider
    self.layout = layout
    self.sizeProvider = sizeProvider
    self.responder = responder
    self.presenter = presenter
  }
  
  public var numberOfItems: Int {
    return dataProvider.numberOfItems
  }
  public func view(at: Int) -> UIView {
    return viewProvider.view(at: at)
  }
  public func update(view: UIView, at: Int) {
    viewProvider.update(view: view as! View, with: dataProvider.data(at: at), at: at)
  }
  public func identifier(at: Int) -> String {
    return dataProvider.identifier(at: at)
  }

  public func layout(collectionSize: CGSize) {
    layout._layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
  }
  public var contentSize: CGSize {
    return layout.contentSize
  }
  public func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }
  public func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    return layout.visibleIndexes(activeFrame: activeFrame)
  }

  public func willReload() {
    responder.willReload()
  }
  public func didReload() {
    responder.didReload()
  }
  public func willDrag(cell: UIView, at:Int) -> Bool {
    return responder.willDrag(cell: cell, at: at)
  }
  public func didDrag(cell: UIView, at:Int) {
    responder.didDrag(cell: cell, at: at)
  }
  public func moveItem(at: Int, to: Int) -> Bool {
    return responder.moveItem(at: at, to: to)
  }
  public func didTap(cell: UIView, at: Int) {
    responder.didTap(cell: cell, index: at)
  }
  
  public func prepareForPresentation(collectionView: CollectionView) {
    presenter.prepare(collectionView: collectionView)
  }
  public func shift(delta: CGPoint) {
    presenter.shift(delta: delta)
  }
  public func insert(view: UIView, at: Int, frame: CGRect) {
    presenter.insert(view: view, at: at, frame: frame)
  }
  public func delete(view: UIView, at: Int, frame: CGRect) {
    presenter.delete(view: view, at: at, frame: frame)
  }
  public func update(view: UIView, at: Int, frame: CGRect) {
    presenter.update(view: view, at: at, frame: frame)
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
  open func willDrag(cell: UIView, at:Int) -> Bool {
    return false
  }
  open func didDrag(cell: UIView, at:Int) {}
  open func moveItem(at: Int, to: Int) -> Bool {
    return false
  }
  open func didTap(cell: UIView, at: Int) {}
  
  open func prepareForPresentation(collectionView: CollectionView) {}
  open func shift(delta: CGPoint) {}
  open func insert(view: UIView, at: Int, frame: CGRect) {}
  open func delete(view: UIView, at: Int, frame: CGRect) {}
  open func update(view: UIView, at: Int, frame: CGRect) {}
}
