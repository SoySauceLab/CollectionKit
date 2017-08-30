//
//  TestUils.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-30.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

extension CollectionLayout where Data == CGSize {

  func mockLayout(parentSize: (CGFloat, CGFloat) = (300, 300), _ childSizes: (CGFloat, CGFloat)...) {
    _layout(collectionSize: CGSize(width: parentSize.0, height: parentSize.1),
            dataProvider: ArrayDataProvider(data: sizes(childSizes)),
            sizeProvider: { (index, data, collectionSize) -> CGSize in
              return data
    })
  }

}

func sizes(_ s: [(CGFloat, CGFloat)]) -> [CGSize] {
  return s.map { CGSize(width: $0.0, height: $0.1) }
}

func sizes(_ s: (CGFloat, CGFloat)...) -> [CGSize] {
  return sizes(s)
}

func frames(_ f: [(CGFloat, CGFloat, CGFloat, CGFloat)]) -> [CGRect] {
  return f.map { CGRect(x: $0.0, y: $0.1, width: $0.2, height: $0.3) }
}

func frames(_ f: (CGFloat, CGFloat, CGFloat, CGFloat)...) -> [CGRect] {
  return frames(f)
}
