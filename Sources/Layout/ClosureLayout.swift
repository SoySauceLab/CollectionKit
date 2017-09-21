//
//  ClosureLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class Closurelayout<Data>: SimpleLayout<Data> {
  public var frameProvider: (Int, Data, CGSize) -> CGRect

  public init(frameProvider: @escaping (Int, Data, CGSize) -> CGRect) {
    self.frameProvider = frameProvider
    super.init()
  }

  public override func simpleLayout(collectionSize: CGSize,
                                    dataProvider: CollectionDataProvider<Data>,
                                    sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []
    for i in 0..<dataProvider.numberOfItems {
      let frame = frameProvider(i, dataProvider.data(at: i), collectionSize)
      frames.append(frame)
    }
    return frames
  }
}
