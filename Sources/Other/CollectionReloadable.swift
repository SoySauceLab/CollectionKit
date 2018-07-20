//
//  CollectionReloadable.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-25.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

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
  public func setNeedsInvalidateLayout() {
    collectionView?.setNeedsInvalidateLayout()
  }
}

internal class CollectionViewManager {
  static let shared: CollectionViewManager = {
    CollectionView.swizzleAdjustContentOffset() // smartly using dispatch_once
    return CollectionViewManager()
  }()

  var collectionViews = NSHashTable<CollectionView>.weakObjects()

  func register(collectionView: CollectionView) {
    collectionViews.add(collectionView)
  }

  func collectionView(for reloadable: CollectionReloadable) -> CollectionView? {
    for collectionView in collectionViews.allObjects {
      if let provider = collectionView.provider, provider.hasReloadable(reloadable) {
        return collectionView
      }
    }
    return nil
  }
}

// https://github.com/SoySauceLab/CollectionKit/issues/63
// UIScrollView has a weird behavior where its contentOffset resets to .zero when
// frame is assigned.
// this swizzling fixed the issue. where the scrollview would jump during scroll
extension UIScrollView {
  @objc func collectionKitAdjustContentOffsetIfNecessary(_ animated: Bool) {
    guard !(self is CollectionView) || !isDragging && !isDecelerating else { return }
    self.perform(#selector(CollectionView.collectionKitAdjustContentOffsetIfNecessary))
  }

  static func swizzleAdjustContentOffset() {
    let encoded = String("==QeyF2czV2Yl5kZJRXZzZmZPRnblRnbvNEdzVnakF2X".reversed())
    let originalMethodName = String(data: Data(base64Encoded: encoded)!, encoding: .utf8)!
    let originalSelector = NSSelectorFromString(originalMethodName)
    let swizzledSelector = #selector(CollectionView.collectionKitAdjustContentOffsetIfNecessary)
    let originalMethod = class_getInstanceMethod(self, originalSelector)
    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
  }
}
