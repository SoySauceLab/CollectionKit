//
//  ZoomAnimator.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

open class ZoomAnimator: Animator {
  open override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.update(collectionView: collectionView, view: view, at: at, frame: frame)
    let bounds = CGRect(origin: .zero, size: collectionView.bounds.size)
    let absolutePosition = frame.center - collectionView.contentOffset
    let scale = 1 - max(0, absolutePosition.distance(bounds.center) - 150) / (max(bounds.width, bounds.height) - 150)
    view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
  }
}
