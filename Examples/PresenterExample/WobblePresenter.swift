//
//  WobblePresenter.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit
import YetAnotherAnimationLibrary

open class WobblePresenter: CollectionPresenter {
  public var sensitivity: CGPoint = CGPoint(x: 1, y: 1)

  open override func shift(collectionView: CollectionView, delta: CGPoint, view: UIView, at: Int, frame: CGRect) {
    view.center += delta
    view.yaal.center.updateWithCurrentState()
  }

  open override func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.insert(collectionView: collectionView, view: view, at: at, frame: frame)
    let delta = collectionView.scrollVelocity * 8
    view.bounds.size = frame.bounds.size
    let cellDiff = frame.center - collectionView.contentOffset - collectionView.screenDragLocation
    let resistance = (cellDiff * sensitivity).distance(.zero) / 1000
    let newCenterDiff = delta * resistance
    let constrainted = CGPoint(x: delta.x > 0 ? min(delta.x, newCenterDiff.x) : max(delta.x, newCenterDiff.x),
                               y: delta.y > 0 ? min(delta.y, newCenterDiff.y) : max(delta.y, newCenterDiff.y))
    view.center += constrainted
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
    view.center += constrainted
    view.yaal.center.updateWithCurrentState()
    view.yaal.center.animateTo(frame.center, stiffness: 250, damping: 30, threshold:0.5)
  }
}
