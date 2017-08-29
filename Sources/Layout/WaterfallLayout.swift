//
//  WaterfallLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class WaterfallLayout<Data>: AxisDependentLayout<Data> {
  public var columns: Int
  public var padding: CGFloat
  private var columnWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(columns: Int = 1, insets: UIEdgeInsets = .zero, padding: CGFloat = 10, axis: Axis = .vertical) {
    self.columns = columns
    self.padding = padding
    super.init(insets: insets)
    self.axis = axis
  }

  public override func layout(collectionSize: CGSize,
                       dataProvider: CollectionDataProvider<Data>,
                       sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []

    let columnWidth = (secondary(collectionSize) - CGFloat(columns - 1) * padding) / CGFloat(columns)
    var columnHeight = Array<CGFloat>(repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minHeight: (Int, CGFloat) = (0, columnHeight[0])
      for (index, height) in columnHeight.enumerated() {
        if height < minHeight.1 {
          minHeight = (index, height)
        }
      }
      return minHeight
    }

    for i in 0..<dataProvider.numberOfItems {
      var cellSize = sizeProvider(i, dataProvider.data(at: i), size(primary: primary(collectionSize), secondary: columnWidth))
      cellSize = size(primary: primary(cellSize), secondary: columnWidth)
      let (columnIndex, offsetY) = getMinColomn()
      columnHeight[columnIndex] += primary(cellSize) + padding
      let frame = CGRect(origin: point(primary: offsetY, secondary: CGFloat(columnIndex) * (columnWidth + padding)), size: cellSize)
      frames.append(frame)
    }

    return frames
  }
}
