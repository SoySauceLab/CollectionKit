//
//  EdgeShrinkAnimator.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

open class EdgeShrinkAnimator: Animator {
  open override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    super.update(collectionView: collectionView, view: view, at: at, frame: frame)
    let effectiveRange: ClosedRange<CGFloat> = -500...16
    let absolutePosition = frame.origin - collectionView.contentOffset
    if absolutePosition.x < effectiveRange.lowerBound {
      view.transform = .identity
      return
    }
    let scale = (absolutePosition.x.clamp(effectiveRange.lowerBound, effectiveRange.upperBound) - effectiveRange.lowerBound) / (effectiveRange.upperBound - effectiveRange.lowerBound)
    let translation = absolutePosition.x < effectiveRange.upperBound ? effectiveRange.upperBound - absolutePosition.x - (1 - scale) / 2 * frame.width : 0
    view.transform = CGAffineTransform.identity.translatedBy(x: translation, y: 0).scaledBy(x: scale, y: scale)
  }
}
