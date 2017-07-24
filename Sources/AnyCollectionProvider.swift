//
//  AnyCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol AnyCollectionProvider: CollectionContext {
  // data
  var numberOfItems: Int { get }
  func identifier(at: Int) -> String
  
  // view
  func view(at: Int) -> UIView
  func update(view: UIView, at: Int)
  
  // layout
  func layout(collectionSize: CGSize)
  
  func visibleIndexes(activeFrame: CGRect) -> Set<Int>
  var contentSize: CGSize { get }
  func frame(at: Int) -> CGRect
  
  // event
  func willReload()
  func didReload()
  func willDrag(view: UIView, at:Int) -> Bool
  func didDrag(view: UIView, at:Int)
  func moveItem(at: Int, to: Int) -> Bool
  func didTap(view: UIView, at: Int)
  
  // presentation
  func prepareForPresentation(collectionView: CollectionView)
  func shift(delta: CGPoint)
  func insert(view: UIView, at: Int, frame: CGRect)
  func delete(view: UIView, at: Int, frame: CGRect)
  func update(view: UIView, at: Int, frame: CGRect)
  
  // determines if a context belongs to current provider
  func hasContext(_ context: CollectionContext) -> Bool
}

extension AnyCollectionProvider {
  public func hasContext(_ context: CollectionContext) -> Bool {
    return context === self
  }
}

class CollectionViewManager {
  static let shared = CollectionViewManager()
  var collectionViews = NSHashTable<CollectionView>.weakObjects()
  func register(collectionView: CollectionView) {
    collectionViews.add(collectionView)
  }
  internal func reloadData(context: CollectionContext) {
    for collectionView in collectionViews.allObjects {
      if collectionView.provider.hasContext(context) {
        collectionView.reloadData()
      }
    }
  }
  internal func setNeedsReload(context: CollectionContext) {
    for collectionView in collectionViews.allObjects {
      if collectionView.provider.hasContext(context) {
        collectionView.setNeedsReload()
      }
    }
  }
}

public protocol CollectionContext: class {
  func reloadData()
  func setNeedsReload()
}

extension CollectionContext {
  public func reloadData() {
    CollectionViewManager.shared.reloadData(context: self)
  }
  public func setNeedsReload() {
    CollectionViewManager.shared.setNeedsReload(context: self)
  }
}
