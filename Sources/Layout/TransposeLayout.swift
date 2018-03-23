//
//  TransposeLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class TransposeLayout<Data>: WrapperLayout<Data> {

  open override var contentSize: CGSize {
    return rootLayout.contentSize.transposed
  }

  open override func layout(collectionSize: CGSize,
                            dataProvider: CollectionDataProvider<Data>,
                            sizeProvider: @escaping (Int, Data, CGSize) -> CGSize) {
    rootLayout.layout(collectionSize: collectionSize.transposed,
                      dataProvider: dataProvider) {
                        return sizeProvider($0, $1, $2.transposed).transposed
    }
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(visibleFrame: visibleFrame.transposed)
  }

  open override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at).transposed
  }
}
