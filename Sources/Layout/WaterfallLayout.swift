//
//  WaterfallLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

public class WaterfallLayout<Data>: CollectionLayout<Data> {
  public var axis: UILayoutConstraintAxis
  public var columns: Int
  public var padding: CGFloat
  private var columnWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(columns: Int = 1, insets: UIEdgeInsets = .zero, padding: CGFloat = 10, axis: UILayoutConstraintAxis = .vertical) {
    self.columns = columns
    self.axis = axis
    self.padding = padding
    super.init(insets: insets)
  }

  public override func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    super.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)

    let maxSize = collectionSize
    var columnWidth = Array<CGFloat>(repeating: 0, count: columns)

    func getMinColomn() -> (Int, CGFloat) {
      var minWidth: (Int, CGFloat) = (0, columnWidth[0])
      for (index, width) in columnWidth.enumerated() {
        if width < minWidth.1 {
          minWidth = (index, width)
        }
      }
      return minWidth
    }

    if axis == .vertical {
      for i in 0..<dataProvider.numberOfItems {
        let avaliableHeight = (maxSize.width - CGFloat(columnWidth.count - 1) * padding) / CGFloat(columnWidth.count)
        var cellSize = sizeProvider(i, dataProvider.data(at: i), CGSize(width: avaliableHeight, height: collectionSize.width))
        cellSize.width = avaliableHeight
        let (columnIndex, offsetY) = getMinColomn()
        columnWidth[columnIndex] += cellSize.height + padding
        let frame = CGRect(origin: CGPoint(x: CGFloat(columnIndex) * (avaliableHeight + padding),
                                           y: offsetY), size: cellSize)
        frames.append(frame)
      }
      visibleIndexSorter = CollectionVerticalVisibleIndexSorter(frames: frames)
    } else {
      for i in 0..<dataProvider.numberOfItems {
        let avaliableHeight = (maxSize.height - CGFloat(columnWidth.count - 1) * padding) / CGFloat(columnWidth.count)
        var cellSize = sizeProvider(i, dataProvider.data(at: i), CGSize(width: collectionSize.width, height: avaliableHeight))
        cellSize.height = avaliableHeight
        let (rowIndex, offsetX) = getMinColomn()
        columnWidth[rowIndex] += cellSize.width + padding
        let frame = CGRect(origin: CGPoint(x: offsetX,
                                           y: CGFloat(rowIndex) * (avaliableHeight + padding)), size: cellSize)
        frames.append(frame)
      }
      visibleIndexSorter = CollectionHorizontalVisibleIndexSorter(frames: frames)
    }
  }
}
