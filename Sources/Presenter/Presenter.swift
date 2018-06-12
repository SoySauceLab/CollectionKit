//
//  CollectionPresenter.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class FadePresenter: BaseSimplePresenter {
  open override func hide(view: UIView) {
    view.alpha = 0
  }
  open override func show(view: UIView) {
    view.alpha = 1
  }
}

open class ScalePresenter: BaseSimplePresenter {
  open override func hide(view: UIView) {
    view.alpha = 0
    view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
  }
  open override func show(view: UIView) {
    view.alpha = 1
    view.transform = CGAffineTransform.identity
  }
}

open class BaseSimplePresenter: Presenter {
  public var updateAnimationDuration: TimeInterval = 0.2

  open func hide(view: UIView) {}

  open func show(view: UIView) {}

  open override func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.insert(collectionView: collectionView, view: view, at: at, frame: frame)
    if collectionView.reloading, collectionView.hasReloaded, collectionView.bounds.intersects(frame) {
      hide(view: view)
      UIView.animate(withDuration: 0.2, animations: {
        self.show(view: view)
      })
    }
  }

  open override func delete(collectionView: CollectionView, view: UIView) {
    if collectionView.reloading, collectionView.bounds.intersects(view.frame) {
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

open class Presenter {
  open func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    view.bounds.size = frame.bounds.size
    view.center = frame.center
  }
  open func delete(collectionView: CollectionView, view: UIView) {
    view.recycleForCollectionKitReuse()
  }
  open func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    if view.bounds.size != frame.bounds.size {
      view.bounds.size = frame.bounds.size
    }
    if view.center != frame.center {
      view.center = frame.center
    }
  }
  open func shift(collectionView: CollectionView, delta: CGPoint, view: UIView, at: Int, frame: CGRect) {}
  public init() {}
}
