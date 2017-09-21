//
//  OverlayLayout.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2017-08-29.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class OverlayLayout<Data>: SimpleLayout<Data> {
  public override func simpleLayout(collectionSize: CGSize,
                                    dataProvider: CollectionDataProvider<Data>,
                                    sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []
    for i in 0..<dataProvider.numberOfItems {
      let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      frames.append(CGRect(origin: .zero, size: size))
    }
    return frames
  }
}
