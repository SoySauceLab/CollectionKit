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
    static var animator = "animator"
    static var currentAnimator = "currentAnimator"
  }

  internal var reuseManager: CollectionReuseViewManager? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.reuseManager) as? CollectionReuseViewManager }
    set { objc_setAssociatedObject(self, &AssociatedKeys.reuseManager, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  public var collectionAnimator: Animator? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.animator) as? Animator }
    set {
      if collectionAnimator === currentCollectionAnimator {
        currentCollectionAnimator = newValue
      }
      objc_setAssociatedObject(self, &AssociatedKeys.animator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  internal var currentCollectionAnimator: Animator? {
    get { return objc_getAssociatedObject(self, &AssociatedKeys.currentAnimator) as? Animator }
    set { objc_setAssociatedObject(self, &AssociatedKeys.currentAnimator,
                                   newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
  }

  public func recycleForCollectionKitReuse() {
    if let reuseManager = reuseManager {
      reuseManager.queue(view: self)
    } else {
      removeFromSuperview()
    }
  }
}
