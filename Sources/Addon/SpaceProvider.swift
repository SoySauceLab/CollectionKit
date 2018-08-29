//
//  SpaceProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class SpaceProvider: EmptyCollectionProvider {
  public enum SpaceSizeStrategy {
    case fill
    case absolute(CGFloat)
  }
  open var sizeStrategy: (SpaceSizeStrategy, SpaceSizeStrategy)
  public init(sizeStrategy: (SpaceSizeStrategy, SpaceSizeStrategy) = (.fill, .fill)) {
    self.sizeStrategy = sizeStrategy
    super.init()
  }
  var _contentSize: CGSize = .zero
  open override var contentSize: CGSize {
    return _contentSize
  }
  open override func layout(collectionSize: CGSize) {
    let width: CGFloat, height: CGFloat
    switch sizeStrategy.0 {
    case .fill: width = collectionSize.width
    case .absolute(let value): width = value
    }
    switch sizeStrategy.1 {
    case .fill: height = collectionSize.height
    case .absolute(let value): height = value
    }
    _contentSize = CGSize(width: width, height: height)
  }
}
