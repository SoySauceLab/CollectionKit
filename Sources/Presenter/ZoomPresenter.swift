//
//  ZoomPresenter.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class ZoomPresenter: CollectionPresenter {
  open override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.update(collectionView: collectionView, view: view, at: at, frame: frame)
    let collectionViewBounds = CGRect(origin: .zero, size: collectionView.bounds.size)
    let absolutePosition = frame.center - collectionView.contentOffset
    let scale = 1 - max(0, absolutePosition.distance(collectionViewBounds.center) - 200) / (max(collectionViewBounds.width, collectionViewBounds.height) - 200)
    view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
  }
}
