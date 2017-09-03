//
//  UIView+CollectionKit.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

extension UIView {
  private struct AssociatedKeys {
    static var reuseManager = "reuseManager"
    static var presenter = "presenter"
    static var currentPresenter = "currentPresenter"
  }

  internal var reuseManager: CollectionReuseViewManager? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.reuseManager) as? CollectionReuseViewManager }
    set { objc_setAssociatedObject(self, &AssociatedKeys.reuseManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  public var collectionPresenter: CollectionPresenter? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.presenter) as? CollectionPresenter }
    set {
      if collectionPresenter === currentCollectionPresenter {
        currentCollectionPresenter = newValue
      }
      objc_setAssociatedObject(self, &AssociatedKeys.presenter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  internal var currentCollectionPresenter: CollectionPresenter? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.currentPresenter) as? CollectionPresenter }
    set { objc_setAssociatedObject(self, &AssociatedKeys.currentPresenter,
                                   newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  public func recycleForCollectionKitReuse() {
    removeFromSuperview()
    reuseManager?.queue(view: self)
  }
}
