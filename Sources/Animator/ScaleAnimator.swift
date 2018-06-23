//
//  ScaleAnimator.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-16.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class ScaleAnimator: BaseSimpleAnimator {
  open override func hide(view: UIView) {
    view.alpha = 0
    view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
  }
  open override func show(view: UIView) {
    view.alpha = 1
    view.transform = CGAffineTransform.identity
  }
}
