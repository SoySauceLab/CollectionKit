//
//  CollectionSizeProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionSizeProvider<Data> {
  open func size(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
    return CGSize(width: 50, height: 50)
  }
  public init() {}
}

open class ClosureSizeProvider<Data>: CollectionSizeProvider<Data> {
  public var sizeProvider: (Int, Data, CGSize) -> CGSize
  
  public init(sizeProvider: @escaping (Int, Data, CGSize) -> CGSize = { _,_,_ in return .zero }) {
    self.sizeProvider = sizeProvider
  }
  
  open override func size(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
    return self.sizeProvider(at, data, collectionSize)
  }
}
