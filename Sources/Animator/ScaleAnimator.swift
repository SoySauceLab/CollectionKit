//
//  ScaleAnimator.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-16.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class ScaleAnimator: FadeAnimator {
  open var scale: CGFloat = 0.5

  open override func hide(view: UIView) {
    super.hide(view: view)
    view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
  }

  open override func show(view: UIView) {
    super.show(view: view)
    view.transform = CGAffineTransform.identity
  }
}
