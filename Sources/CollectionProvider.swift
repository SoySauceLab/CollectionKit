//
//  CollectionProvider.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-18.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol AnyCollectionProvider {
  // data
  var numberOfItems: Int { get }
  func identifier(at: Int) -> String

  // view
  func view(at: Int) -> UIView
  func update(view: UIView, at: Int)

  // layout
  func prepareLayout(maxSize: CGSize)
  var insets: UIEdgeInsets { get }
  func frame(at: Int) -> CGRect

  // event
  func willReload()
  func didReload()
  func willDrag(cell: UIView, at:Int) -> Bool
  func didDrag(cell: UIView, at:Int)
  func moveItem(at: Int, to: Int) -> Bool
  func didTap(cell: UIView, at: Int)

  // presentation
  func prepareForPresentation(collectionView: CollectionView)
  func shift(delta: CGPoint)
  func insert(view: UIView, at: Int, frame: CGRect)
  func delete(view: UIView, at: Int, frame: CGRect)
  func update(view: UIView, at: Int, frame: CGRect)
}

public class CollectionProvider<Data, View>: AnyCollectionProvider where View: UIView
{
  public var dataProvider: CollectionDataProvider<Data>
  public var viewProvider: CollectionViewProvider<Data, View>
  public var layoutProvider: CollectionLayoutProvider<Data>
  public var responder: CollectionResponder
  public var presenter: CollectionPresenter

  public init(dataProvider: CollectionDataProvider<Data>, viewProvider: CollectionViewProvider<Data, View>, layoutProvider: CollectionLayoutProvider<Data>, responder: CollectionResponder = CollectionResponder(), presenter: CollectionPresenter = CollectionPresenter()) {
    self.dataProvider = dataProvider
    self.viewProvider = viewProvider
    self.layoutProvider = layoutProvider
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

  public func prepareLayout(maxSize: CGSize) {
    layoutProvider.prepareLayout(maxSize: maxSize)
  }
  public var insets: UIEdgeInsets {
    return layoutProvider.insets
  }
  public func frame(at: Int) -> CGRect {
    return layoutProvider.frame(with: dataProvider.data(at: at), at: at)
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
