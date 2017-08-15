//
//  EdgeShrinkPresenter.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

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
