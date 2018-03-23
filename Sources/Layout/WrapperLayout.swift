//
//  WrapperLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-11.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class WrapperLayout<Data>: CollectionLayout<Data> {
  var rootLayout: CollectionLayout<Data>

  public init(_ rootLayout: CollectionLayout<Data>) {
    self.rootLayout = rootLayout
  }

  open override var contentSize: CGSize {
    return rootLayout.contentSize
  }

  open override func layout(collectionSize: CGSize,
                            dataProvider: CollectionDataProvider<Data>,
                            sizeProvider: @escaping (Int, Data, CGSize) -> CGSize) {
    rootLayout.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(visibleFrame: visibleFrame)
  }

  open override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at)
  }
}
