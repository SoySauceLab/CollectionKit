//
//  CollectionReloadable.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-25.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

public protocol CollectionReloadable: class {
  func reloadData()
  func setNeedsReload()
}

extension CollectionReloadable {
  public func reloadData() {
    CollectionViewManager.shared.reloadData(reloadable: self)
  }
  public func setNeedsReload() {
    CollectionViewManager.shared.setNeedsReload(reloadable: self)
  }
}

internal class CollectionViewManager {
  static let shared = CollectionViewManager()
  var collectionViews = NSHashTable<CollectionView>.weakObjects()
  func register(collectionView: CollectionView) {
    collectionViews.add(collectionView)
  }
  internal func reloadData(reloadable: CollectionReloadable) {
    for collectionView in collectionViews.allObjects {
      if collectionView.provider.hasReloadable(reloadable) {
        collectionView.reloadData()
      }
    }
  }
  internal func setNeedsReload(reloadable: CollectionReloadable) {
    for collectionView in collectionViews.allObjects {
      if collectionView.provider.hasReloadable(reloadable) {
        collectionView.setNeedsReload()
      }
    }
  }
}
