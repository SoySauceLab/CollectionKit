//
//  UIView+CollectionKit.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

let defaultCollectionPresenter = CollectionPresenter()
extension UIView {
  private struct AssociatedKeys {
    static var reuseManager = "reuseManager"
    static var presenter = "presenter"
  }
  
  internal var reuseManager: CollectionReuseViewManager? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.reuseManager) as? CollectionReuseViewManager }
    set { objc_setAssociatedObject(self, &AssociatedKeys.reuseManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  public var collectionPresenter: CollectionPresenter? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.presenter) as? CollectionPresenter }
    set { objc_setAssociatedObject(self, &AssociatedKeys.presenter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }
  
  public func recycleForCollectionKitReuse() {
    removeFromSuperview()
    reuseManager?.queue(view: self)
  }
}
