//
//  CollectionReloadable.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-25.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

public protocol CollectionReloadable: class {
  var collectionView: CollectionView? { get }
  func reloadData()
  func setNeedsReload()
}

extension CollectionReloadable {
  public var collectionView: CollectionView? {
    return CollectionViewManager.shared.collectionView(for: self)
  }
  public func reloadData() {
    collectionView?.reloadData()
  }
  public func setNeedsReload() {
    collectionView?.setNeedsReload()
  }
}

internal class CollectionViewManager {
  static let shared = CollectionViewManager()

  var collectionViews = NSHashTable<CollectionView>.weakObjects()

  func register(collectionView: CollectionView) {
    collectionViews.add(collectionView)
  }

  internal func collectionView(for reloadable: CollectionReloadable) -> CollectionView? {
    for collectionView in collectionViews.allObjects {
      if collectionView.provider.hasReloadable(reloadable) {
        return collectionView
      }
    }
    return nil
  }
}
