//
//  CollectionAnimator.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class Animator {
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
