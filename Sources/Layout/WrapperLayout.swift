//
//  WrapperLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-11.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class WrapperLayout: Layout {
  var rootLayout: Layout

  public init(_ rootLayout: Layout) {
    self.rootLayout = rootLayout
  }

  open override var contentSize: CGSize {
    return rootLayout.contentSize
  }

  open override func layout(context: LayoutContext) {
    rootLayout.layout(context: context)
  }

  open override func visible(in visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect) {
    return rootLayout.visible(in: visibleFrame)
  }

  open override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at)
  }
}
