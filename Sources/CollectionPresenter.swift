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
  open func prepare(collectionView: CollectionView) {}
  open func insert(view: UIView, at: Int, frame: CGRect) {
    view.bounds = frame.bounds
    view.center = frame.center
  }
  open func delete(view: UIView, at: Int, frame: CGRect) {
    view.removeFromSuperview()
    CollectionReuseViewManager.shared.queue(view: view)
  }
  open func update(view: UIView, at: Int, frame: CGRect) {
    view.bounds = frame.bounds
    view.center = frame.center
  }
  open func shift(delta: CGPoint) {}
  public init() {}
}

open class WobblePresenter: CollectionPresenter {
  weak var collectionView: CollectionView?
  var screenDragLocation: CGPoint = .zero
  var contentOffset: CGPoint!
  var delta: CGPoint = .zero
  var sensitivity: CGPoint = CGPoint(x: 1, y: 1)
  
  open override func prepare(collectionView: CollectionView) {
    self.collectionView = collectionView
    screenDragLocation = collectionView.screenDragLocation
    let oldContentOffset = contentOffset ?? collectionView.contentOffset
    contentOffset = collectionView.contentOffset
    delta = contentOffset - oldContentOffset
  }

  open override func shift(delta: CGPoint) {
    contentOffset = contentOffset + delta
    for cell in collectionView?.visibleCells ?? [] {
      cell.center = cell.center + delta
      cell.yaal.center.updateWithCurrentState()
    }
  }
  
  open override func delete(view: UIView, at: Int, frame: CGRect) {
    view.yaal.center.stop()
    super.delete(view: view, at: at, frame: frame)
  }
  
  open override func update(view: UIView, at: Int, frame: CGRect) {
    view.bounds = frame.bounds
    let cellDiff = frame.center - contentOffset - screenDragLocation
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
  var collectionViewBounds: CGRect = .zero
  var contentOffset: CGPoint = .zero
  
  open override func prepare(collectionView: CollectionView) {
    super.prepare(collectionView: collectionView)
    contentOffset = collectionView.contentOffset
    collectionViewBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
  }
  
  open override func update(view: UIView, at: Int, frame: CGRect) {
    super.update(view: view, at: at, frame: frame)
    let absolutePosition = frame.center - contentOffset
    let scale = 1 - max(0, absolutePosition.distance(collectionViewBounds.center) - 200) / (max(collectionViewBounds.width, collectionViewBounds.height) - 200)
    view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
  }
  
  open override func delete(view: UIView, at: Int, frame: CGRect) {
    view.transform = .identity
    super.delete(view: view, at: at, frame: frame)
  }
}


open class EdgeShrinkPresenter: CollectionPresenter {
  var collectionViewBounds: CGRect = .zero
  var contentOffset: CGPoint = .zero
  
  var effectiveRange: ClosedRange<CGFloat> = -200...0
  
  open override func prepare(collectionView: CollectionView) {
    super.prepare(collectionView: collectionView)
    contentOffset = collectionView.contentOffset
    collectionViewBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
  }
  
  open override func update(view: UIView, at: Int, frame: CGRect) {
    super.update(view: view, at: at, frame: frame)
    let absolutePosition = frame.origin - contentOffset
    let scale = (absolutePosition.x.clamp(effectiveRange.lowerBound, effectiveRange.upperBound) - effectiveRange.lowerBound) / (effectiveRange.upperBound - effectiveRange.lowerBound)
    let alpha = scale
    let translation = absolutePosition.x < effectiveRange.upperBound ? effectiveRange.upperBound - absolutePosition.x : 0
    view.alpha = alpha
    view.transform = CGAffineTransform.identity.translatedBy(x: translation, y: 0).scaledBy(x: scale, y: scale)
  }
  
  open override func delete(view: UIView, at: Int, frame: CGRect) {
    view.transform = .identity
    view.alpha = 1
    super.delete(view: view, at: at, frame: frame)
  }
}
