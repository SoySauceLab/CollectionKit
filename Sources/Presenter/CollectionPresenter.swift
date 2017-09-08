//
//  CollectionPresenter.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionPresenter {

  public enum CollectionPresenterAnimation {
    case fade
    case scale
  }

  public enum CollectionPresenterUpdateAnimation {
    case normal
  }

  open var insertAnimation: CollectionPresenterAnimation?
  open var deleteAnimation: CollectionPresenterAnimation?
  open var updateAnimation: CollectionPresenterUpdateAnimation?

  open func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    view.bounds.size = frame.bounds.size
    view.center = frame.center
    if collectionView.reloading, collectionView.hasReloaded, collectionView.bounds.intersects(frame),
      let insertAnimation = insertAnimation {
      switch insertAnimation {
      case .fade:
        view.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
          view.alpha = 1
        })
      case .scale:
        view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
        view.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
          view.transform = CGAffineTransform.identity
          view.alpha = 1
        })
      }
    }
  }
  open func delete(collectionView: CollectionView, view: UIView) {
    if collectionView.reloading, collectionView.bounds.intersects(view.frame), let deleteAnimation = deleteAnimation {
      switch deleteAnimation {
      case .fade:
        UIView.animate(withDuration: 0.2, animations: {
          view.alpha = 0
        }, completion: { _ in
          if !collectionView.visibleCells.contains(view) {
            view.recycleForCollectionKitReuse()
            view.alpha = 1
          }
        })
      case .scale:
        UIView.animate(withDuration: 0.2, animations: {
          view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
          view.alpha = 0
        }, completion: { _ in
          if !collectionView.visibleCells.contains(view) {
            view.recycleForCollectionKitReuse()
            view.transform = CGAffineTransform.identity
            view.alpha = 1
          }
        })
      }
    } else {
      view.recycleForCollectionKitReuse()
    }
  }
  open func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    if view.bounds.size != frame.bounds.size {
      view.bounds.size = frame.bounds.size
    }
    if let updateAnimation = updateAnimation {
      switch updateAnimation {
      case .normal:
        UIView.animate(withDuration: 0.2) {
          view.center = frame.center
        }
      }
    } else {
      view.center = frame.center
    }
  }
  open func shift(collectionView: CollectionView, delta: CGPoint, view: UIView, at: Int, frame: CGRect) {}
  public init() {}
}
