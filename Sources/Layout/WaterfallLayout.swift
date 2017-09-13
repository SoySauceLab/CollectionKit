//
//  WaterfallLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class WaterfallLayout<Data>: VerticalSimpleLayout<Data> {
  public var columns: Int
  public var spacing: CGFloat
  private var columnWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(columns: Int = 1, spacing: CGFloat = 10) {
    self.columns = columns
    self.spacing = spacing
    super.init()
  }

  public override func simpleLayout(collectionSize: CGSize,
                                    dataProvider: CollectionDataProvider<Data>,
                                    sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []

    let columnWidth = (collectionSize.width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    var columnHeight = [CGFloat](repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minHeight: (Int, CGFloat) = (0, columnHeight[0])
      for (index, height) in columnHeight.enumerated() where height < minHeight.1 {
        minHeight = (index, height)
      }
      return minHeight
    }

    for i in 0..<dataProvider.numberOfItems {
      var cellSize = sizeProvider(i, dataProvider.data(at: i),
                                  CGSize(width: columnWidth, height: collectionSize.height))
      cellSize = CGSize(width: columnWidth, height: cellSize.height)
      let (columnIndex, offsetY) = getMinColomn()
      columnHeight[columnIndex] += cellSize.height + spacing
      let frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (columnWidth + spacing),
                                         y: offsetY),
                         size: cellSize)
      frames.append(frame)
    }

    return frames
  }
}
