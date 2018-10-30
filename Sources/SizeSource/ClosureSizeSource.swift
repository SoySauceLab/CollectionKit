//
//  ClosureSizeSource.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-10-17.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

public typealias ClosureSizeSourceFn<Data> = (Int, Data, CGSize) -> CGSize

open class ClosureSizeSource<Data>: SizeSource<Data> {
  open var sizeSource: ClosureSizeSourceFn<Data>

  public init(sizeSource: @escaping ClosureSizeSourceFn<Data>) {
    self.sizeSource = sizeSource
    super.init()
  }

  open override func size(at index: Int, data: Data, collectionSize: CGSize) -> CGSize {
    return sizeSource(index, data, collectionSize)
  }
}
