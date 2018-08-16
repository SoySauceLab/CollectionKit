//
//  WaterfallLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class WaterfallLayout: VerticalSimpleLayout {
  public var columns: Int
  public var spacing: CGFloat
  private var columnWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(columns: Int = 2, spacing: CGFloat = 0) {
    self.columns = columns
    self.spacing = spacing
    super.init()
  }

  public override func simpleLayout(context: LayoutContext) -> [CGRect] {
    var frames: [CGRect] = []

    let columnWidth = (context.collectionSize.width - CGFloat(columns - 1) * spacing) / CGFloat(columns)
    var columnHeight = [CGFloat](repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minHeight: (Int, CGFloat) = (0, columnHeight[0])
      for (index, height) in columnHeight.enumerated() where height < minHeight.1 {
        minHeight = (index, height)
      }
      return minHeight
    }

    for i in 0..<context.numberOfItems {
      var cellSize = context.size(at: i, collectionSize: CGSize(width: columnWidth,
                                                                height: context.collectionSize.height))
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
