//
//  ExpandLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-10-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class ExpandLayout<Data>: WrapperLayout<Data> {
  public var activeFrameInsets: UIEdgeInsets

  public init(_ rootLayout: CollectionLayout<Data>, activeFrameInsets: UIEdgeInsets = .zero) {
    self.activeFrameInsets = activeFrameInsets
    super.init(rootLayout)
  }

  open override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(activeFrame: activeFrame.inset(by: -activeFrameInsets))
  }
}

