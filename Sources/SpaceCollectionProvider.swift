//
//  SpaceCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class SpaceCollectionProvider: BaseCollectionProvider {
  public enum SpaceSizeStrategy {
    case fillWidth(height: CGFloat)
    case fillHeight(width: CGFloat)
    case absolute(size: CGSize)
  }
  public var spaceSizeStrategy: SpaceSizeStrategy
  public init(_ spaceSizeStrategy: SpaceSizeStrategy = .fillWidth(height: 10)) {
    self.spaceSizeStrategy = spaceSizeStrategy
  }
  var _contentSize: CGSize = .zero
  open override var contentSize: CGSize {
    return _contentSize
  }
  open override func layout(collectionSize: CGSize) {
    switch spaceSizeStrategy {
    case .fillWidth(let height):
      _contentSize = CGSize(width: collectionSize.width, height: height)
    case .fillHeight(let width):
      _contentSize = CGSize(width: width, height: collectionSize.height)
    case .absolute(let size):
      _contentSize = size
    }
  }
}
