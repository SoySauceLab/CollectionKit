//
//  UIImageSizeSource.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-10-17.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

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
