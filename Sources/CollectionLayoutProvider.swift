//
//  CollectionLayoutProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionLayoutProvider<Data> {
  open var insets: UIEdgeInsets {
    return .zero
  }
  open func prepareLayout(maxSize: CGSize) {}
  open func frame(with data: Data, at: Int) -> CGRect {
    return .zero
  }
  public init() {}
}

public class ClosureLayoutProvider<Data>: CollectionLayoutProvider<Data> {
  public var frameProvider: (Data, Int) -> CGRect

  public init(frameProvider: @escaping (Data, Int) -> CGRect) {
    self.frameProvider = frameProvider
  }

  public override func frame(with data: Data, at: Int) -> CGRect {
    return frameProvider(data, at)
  }
}

open class CustomSizeLayoutProvider<Data>: CollectionLayoutProvider<Data> {
  public var sizeProvider: (Int, Data, CGSize) -> CGSize

  public init(sizeProvider: @escaping (Int, Data, CGSize) -> CGSize = { _,_,_ in return .zero }) {
    self.sizeProvider = sizeProvider
  }
}

public class HorizontalWaterfallLayoutProvider<Data>: CustomSizeLayoutProvider<Data> {
  public var prefferedRowHeight: CGFloat
  private var numRows = 2
  private var rowWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(prefferedRowHeight: CGFloat  = 180, sizeProvider: @escaping (Int, Data, CGSize) -> CGSize = { _,_,_ in return .zero }) {
    self.prefferedRowHeight = prefferedRowHeight
    super.init(sizeProvider: sizeProvider)
  }

  public override func prepareLayout(maxSize: CGSize) {
    self.maxSize = maxSize
    numRows = max(1, Int(maxSize.height / prefferedRowHeight))
    rowWidth = Array<CGFloat>(repeating: 0, count: numRows)
  }

  public override func frame(with data: Data, at: Int) -> CGRect {
    func getMinRow() -> (Int, CGFloat) {
      var minWidth: (Int, CGFloat) = (0, rowWidth[0])
      for (index, width) in rowWidth.enumerated() {
        if width < minWidth.1 {
          minWidth = (index, width)
        }
      }
      return minWidth
    }

    let avaliableHeight = (maxSize.height - CGFloat(rowWidth.count - 1) * 10) / CGFloat(rowWidth.count)
    var cellSize = sizeProvider(at, data, CGSize(width: .infinity, height: avaliableHeight))
    cellSize.height = avaliableHeight
    let (rowIndex, offsetX) = getMinRow()
    rowWidth[rowIndex] += cellSize.width + 10
    return CGRect(origin: CGPoint(x: offsetX, y: CGFloat(rowIndex) * (avaliableHeight + 10)), size: cellSize)
  }
}
