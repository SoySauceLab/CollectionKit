//
//  CollectionPresenter.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import YetAnotherAnimationLibrary

open class CollectionPresenter {

  public enum CollectionPresenterAnimation {
    case fade
    case scale
  }

  open var insertAnimation: CollectionPresenterAnimation?
  open var deleteAnimation: CollectionPresenterAnimation?
  weak var collectionView: CollectionView?
  open func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    view.bounds.size = frame.bounds.size
    view.center = frame.center
    if collectionView.reloading, collectionView.hasReloaded, collectionView.bounds.intersects(frame), let insertAnimation = insertAnimation {
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
  open func delete(collectionView: CollectionView, view: UIView, at: Int) {
    if collectionView.reloading, collectionView.bounds.intersects(view.frame), let deleteAnimation = deleteAnimation {
      switch deleteAnimation {
      case .fade:
        UIView.animate(withDuration: 0.2, animations: {
          view.alpha = 0
        }) { _ in
          if collectionView.visibleCellToIndexMap[view] == nil {
            view.recycleForCollectionKitReuse()
          }
        }
      case .scale:
        UIView.animate(withDuration: 0.2, animations: {
          view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
          view.alpha = 0
        }) { _ in
          if collectionView.visibleCellToIndexMap[view] == nil {
            view.recycleForCollectionKitReuse()
          }
        }
      }
    } else {
      view.recycleForCollectionKitReuse()
    }
  }
  open func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    if view.bounds.size != frame.bounds.size {
      view.bounds.size = frame.bounds.size
    }
    view.center = frame.center
  }
  open func shift(collectionView: CollectionView, delta: CGPoint, view: UIView, at: Int, frame: CGRect) {}
  public init() {}
}

open class WobblePresenter: CollectionPresenter {
  public var sensitivity: CGPoint = CGPoint(x: 1, y: 1)

  open override func shift(collectionView: CollectionView, delta: CGPoint, view: UIView, at: Int, frame: CGRect) {
    view.center = view.center + delta
    view.yaal.center.updateWithCurrentState()
  }

  open override func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.insert(collectionView: collectionView, view: view, at: at, frame: frame)
    let delta = collectionView.scrollVelocity * 4
    view.bounds.size = frame.bounds.size
    let cellDiff = frame.center - collectionView.contentOffset - collectionView.screenDragLocation
    let resistance = (cellDiff * sensitivity).distance(.zero) / 1000
    let newCenterDiff = delta * resistance
    let constrainted = CGPoint(x: delta.x > 0 ? min(delta.x, newCenterDiff.x) : max(delta.x, newCenterDiff.x),
                               y: delta.y > 0 ? min(delta.y, newCenterDiff.y) : max(delta.y, newCenterDiff.y))
    view.center = view.center + constrainted
    view.yaal.center.updateWithCurrentState()
    view.yaal.center.animateTo(frame.center, stiffness: 250, damping: 30, threshold:0.5)
  }

  open override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    let delta = collectionView.scrollVelocity
    view.bounds.size = frame.bounds.size
    let cellDiff = frame.center - collectionView.contentOffset - collectionView.screenDragLocation
    let resistance = (cellDiff * sensitivity).distance(.zero) / 1000
    let newCenterDiff = delta * resistance
    let constrainted = CGPoint(x: delta.x > 0 ? min(delta.x, newCenterDiff.x) : max(delta.x, newCenterDiff.x),
                               y: delta.y > 0 ? min(delta.y, newCenterDiff.y) : max(delta.y, newCenterDiff.y))
    view.center = view.center + constrainted
    view.yaal.center.updateWithCurrentState()
    view.yaal.center.animateTo(frame.center, stiffness: 250, damping: 30, threshold:0.5)
  }
}

open class ZoomPresenter: CollectionPresenter {
  open override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.update(collectionView: collectionView, view: view, at: at, frame: frame)
    let collectionViewBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
    let absolutePosition = frame.center - collectionView.contentOffset
    let scale = 1 - max(0, absolutePosition.distance(collectionViewBounds.center) - 200) / (max(collectionViewBounds.width, collectionViewBounds.height) - 200)
    view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
  }
}


open class EdgeShrinkPresenter: CollectionPresenter {
  
  var effectiveRange: ClosedRange<CGFloat> = -200...0

  open override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.update(collectionView: collectionView, view: view, at: at, frame: frame)
    let collectionViewBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
    let absolutePosition = frame.origin - collectionView.contentOffset
    let scale = (absolutePosition.x.clamp(effectiveRange.lowerBound, effectiveRange.upperBound) - effectiveRange.lowerBound) / (effectiveRange.upperBound - effectiveRange.lowerBound)
    let alpha = scale
    let translation = absolutePosition.x < effectiveRange.upperBound ? effectiveRange.upperBound - absolutePosition.x : 0
    view.alpha = alpha
    view.transform = CGAffineTransform.identity.translatedBy(x: translation, y: 0).scaledBy(x: scale, y: scale)
  }
}
