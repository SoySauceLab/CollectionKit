//
//  SizeSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public typealias ClosureSizeSourceFn<Data> = (Int, Data, CGSize) -> CGSize

open class SizeSource<Data> {

  public init() {}

  // override point for subclass
  open func size(at index: Int, data: Data, collectionSize: CGSize) -> CGSize {
    return collectionSize
  }
}

open class UIImageSizeSource: SizeSource<UIImage> {
  open override func size(at index: Int, data: UIImage, collectionSize: CGSize) -> CGSize {
    var imageSize = data.size
    if imageSize.width > collectionSize.width {
      imageSize.height /= imageSize.width / collectionSize.width
      imageSize.width = collectionSize.width
    }
    if imageSize.height > collectionSize.height {
      imageSize.width /= imageSize.height / collectionSize.height
      imageSize.height = collectionSize.height
    }
    return imageSize
  }
}

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
