//
//  InverseLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class InverseLayout<Data>: WrapperLayout<Data> {

  open override var contentSize: CGSize {
    return rootLayout.contentSize.inverted
  }

  override public func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: @escaping (Int, Data, CGSize) -> CGSize) {
    rootLayout.layout(collectionSize: collectionSize.inverted,
                      dataProvider: dataProvider) {
                        return sizeProvider($0, $1, $2.inverted).inverted
    }
  }

  public override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(activeFrame: activeFrame.inverted)
  }

  public override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at).inverted
  }
}
