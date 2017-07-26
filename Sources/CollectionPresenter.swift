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

  public struct CollectionInsertAnimation {
    typealias AnimationBlock = (CollectionView, UIView, Int, CGRect) -> Void
    internal let animationBlock: AnimationBlock
    static let fade = CollectionInsertAnimation { (_, view, _, frame) in
      view.alpha = 0
      UIView.animate(withDuration: 0.3, animations: {
        view.alpha = 1
      })
    }
    static let scale = CollectionInsertAnimation { (_, view, _, frame) in
      view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
      view.alpha = 0
      UIView.animate(withDuration: 0.3, animations: {
        view.transform = CGAffineTransform.identity
        view.alpha = 1
      })
    }
    static func custom(animation: @escaping AnimationBlock) -> CollectionInsertAnimation {
      return CollectionInsertAnimation(animationBlock: animation)
    }
  }

  open var insertAnimation: CollectionInsertAnimation?
  weak var collectionView: CollectionView?
  open func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    view.bounds.size = frame.bounds.size
    view.center = frame.center
    if let insertAnimation = insertAnimation {
      insertAnimation.animationBlock(collectionView, view, at, frame)
    }
  }
  open func delete(collectionView: CollectionView, view: UIView, at: Int) {
    view.removeFromSuperview()
    view.recycleForCollectionKitReuse()
  }
  open func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    view.bounds.size = frame.bounds.size
    view.center = frame.center
  }
  open func shift(collectionView: CollectionView, delta: CGPoint, view: UIView, at: Int, frame: CGRect) {}
  public init() {}
}

open class WobblePresenter: CollectionPresenter {
  var sensitivity: CGPoint = CGPoint(x: 1, y: 1)

  open override func shift(collectionView: CollectionView, delta: CGPoint, view: UIView, at: Int, frame: CGRect) {
    view.center = view.center + delta
    view.yaal.center.updateWithCurrentState()
  }

  open override func delete(collectionView: CollectionView, view: UIView, at: Int) {
    view.yaal.center.stop()
    super.delete(collectionView: collectionView, view: view, at: at)
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
    view.yaal.center.animateTo(frame.center, stiffness: 200, damping: 30, threshold:0.5)
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
