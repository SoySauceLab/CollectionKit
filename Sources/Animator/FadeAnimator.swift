//
//  FadeAnimator.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-16.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class FadeAnimator: SimpleAnimator {
  open var alpha: CGFloat = 0

  open override func hide(view: UIView) {
    view.alpha = alpha
  }

  open override func show(view: UIView) {
    view.alpha = 1
  }
}
