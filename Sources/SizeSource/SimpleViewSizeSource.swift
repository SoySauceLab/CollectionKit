//
//  SimpleViewSizeSource.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-10-17.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class SimpleViewSizeSource: SizeSource<UIView>, CollectionReloadable {
  public enum ViewSizeStrategy {
    case fill
    case fit
    case absolute(CGFloat)
  }

  public init(sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy)) {
    self.sizeStrategy = sizeStrategy
    super.init()
  }

  open var sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy) {
    didSet { setNeedsInvalidateLayout() }
  }

  open var sizeStrategyOverride: [UIView: (width: ViewSizeStrategy, height: ViewSizeStrategy)] = [:] {
    didSet { setNeedsInvalidateLayout() }
  }

  open override func size(at index: Int, data: UIView, collectionSize: CGSize) -> CGSize {
    let fitSize = data.sizeThatFits(collectionSize)
    let sizeStrategy = sizeStrategyOverride[data] ?? self.sizeStrategy
    let width: CGFloat, height: CGFloat

    switch sizeStrategy.width {
    case .fit: width = fitSize.width
    case .fill: width = collectionSize.width
    case .absolute(let value): width = value
    }
    switch sizeStrategy.height {
    case .fit: height = fitSize.height
    case .fill: height = collectionSize.height
    case .absolute(let value): height = value
    }

    return CGSize(width: width, height: height)
  }
}
