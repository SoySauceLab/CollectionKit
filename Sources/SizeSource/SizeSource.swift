//
//  SizeSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class SizeSource<Data> {

  public init() {}

  // override point for subclass
  open func size(at index: Int, data: Data, collectionSize: CGSize) -> CGSize {
    return collectionSize
  }
}
