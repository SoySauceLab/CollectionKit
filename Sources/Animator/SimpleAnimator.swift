//
//  SimpleAnimator.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-16.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class SimpleAnimator: Animator {
  open var animationDuration: TimeInterval = 0.3
  open var animationOptions: UIView.AnimationOptions = []
  open var useSpringAnimation: Bool = false
  open var springDamping: CGFloat = 0.8

  // override point for subclass
  open func hide(view: UIView) {}
  open func show(view: UIView) {}

  open override func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.insert(collectionView: collectionView, view: view, at: at, frame: frame)
    if collectionView.isReloading, collectionView.hasReloaded, collectionView.bounds.intersects(frame) {
      hide(view: view)
      animate {
        self.show(view: view)
      }
    }
  }

  open override func delete(collectionView: CollectionView, view: UIView) {
    if collectionView.isReloading, collectionView.bounds.intersects(view.frame) {
      animate({
        self.hide(view: view)
      }, completion: { _ in
        if !collectionView.visibleCells.contains(view) {
          view.recycleForCollectionKitReuse()
          self.show(view: view)
        }
      })
    } else {
      view.recycleForCollectionKitReuse()
    }
  }

  open override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    if view.bounds.size != frame.bounds.size {
      view.bounds.size = frame.bounds.size
    }
    animate {
      view.center = frame.center
    }
  }

  open func animate(_ animations: @escaping () -> Void) {
    animate(animations, completion: nil)
  }

  open func animate(_ animations: @escaping () -> Void,
                    completion: ((Bool) -> Void)?) {
    if useSpringAnimation {
      UIView.animate(withDuration: animationDuration,
                     delay: 0,
                     usingSpringWithDamping: springDamping,
                     initialSpringVelocity: 0,
                     options: animationOptions,
                     animations: animations,
                     completion: completion)
    } else {
      UIView.animate(withDuration: animationDuration,
                     delay: 0,
                     options: animationOptions,
                     animations: animations,
                     completion: completion)
    }
  }
}
