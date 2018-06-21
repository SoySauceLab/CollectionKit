//
//  BaseSimpleAnimator.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-16.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class BaseSimpleAnimator: Animator {
  public var updateAnimationDuration: TimeInterval = 0.2

  open func hide(view: UIView) {}

  open func show(view: UIView) {}

  open override func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.insert(collectionView: collectionView, view: view, at: at, frame: frame)
    if collectionView.isReloading, collectionView.hasReloaded, collectionView.bounds.intersects(frame) {
      hide(view: view)
      UIView.animate(withDuration: 0.2, animations: {
        self.show(view: view)
      })
    }
  }

  open override func delete(collectionView: CollectionView, view: UIView) {
    if collectionView.isReloading, collectionView.bounds.intersects(view.frame) {
      UIView.animate(withDuration: 0.2, animations: {
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
    UIView.animate(withDuration: updateAnimationDuration) {
      view.center = frame.center
    }
  }
}
