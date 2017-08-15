//
//  FlowLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class FlowLayout<Data>: CollectionLayout<Data> {
  public var padding: CGFloat

  public init(insets: UIEdgeInsets = .zero, padding: CGFloat = 0) {
    self.padding = padding
    super.init()
    self.insets = insets
  }

  public override func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    super.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)

    var offset = CGPoint.zero
    var currentRowMaxHeight: CGFloat = 0
    for i in 0..<dataProvider.numberOfItems {
      let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      if offset.x + size.width > collectionSize.width, offset.x != 0 {
        offset.x = 0
        offset.y += currentRowMaxHeight + padding
        currentRowMaxHeight = 0
      }
      currentRowMaxHeight = max(currentRowMaxHeight, size.height)
      let frame = CGRect(origin: offset, size: size)
      frames.append(frame)
      offset.x += size.width + padding
    }

    visibleIndexSorter = CollectionVerticalVisibleIndexSorter(frames: frames)
  }
}
