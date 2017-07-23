//
//  CollectionLayoutProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionSizeProvider<Data> {
  open func size(at: Int, data: Data, maxSize: CGSize) -> CGSize {
    return .zero
  }
  public init() {}
}

open class ClosureSizeProvider<Data>: CollectionSizeProvider<Data> {
  public var sizeProvider: (Int, Data, CGSize) -> CGSize

  public init(sizeProvider: @escaping (Int, Data, CGSize) -> CGSize = { _,_,_ in return .zero }) {
    self.sizeProvider = sizeProvider
  }
  
  open override func size(at: Int, data: Data, maxSize: CGSize) -> CGSize {
    return self.sizeProvider(at, data, maxSize)
  }
}

open class CollectionLayoutProvider<Data> {
  private let visibleIndexesManager = CollectionVisibleIndexesManager()

  open var frames: [CGRect] = []
  open func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    frames = []
  }
  
  private var _contentSize: CGSize = .zero
  internal func _layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
    visibleIndexesManager.reload(with: frames)
    _contentSize = frames.reduce(CGRect.zero) { (old, item) in
      old.union(item)
    }.size
  }

  open var contentSize: CGSize {
    return _contentSize
  }
  open func frame(at: Int) -> CGRect {
    return frames[at]
  }
  open func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    return visibleIndexesManager.visibleIndexes(for: activeFrame)
  }
  public init() {}
}

public class ClosureLayoutProvider<Data>: CollectionLayoutProvider<Data> {
  public var frameProvider: (Int, Data, CGSize) -> CGRect

  public init(frameProvider: @escaping (Int, Data, CGSize) -> CGRect) {
    self.frameProvider = frameProvider
  }

  public override func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    super.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
    for i in 0..<dataProvider.numberOfItems {
      let frame = frameProvider(i, dataProvider.data(at: i), collectionSize)
      frames.append(frame)
    }
  }
}

public class HorizontalWaterfallLayoutProvider<Data>: CollectionLayoutProvider<Data> {
  public var prefferedRowHeight: CGFloat
  private var numRows = 2
  private var rowWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(prefferedRowHeight: CGFloat  = 180) {
    self.prefferedRowHeight = prefferedRowHeight
    super.init()
  }

  public override func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    super.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
    
    let maxSize = collectionSize
    let numRows = max(1, Int(maxSize.height / prefferedRowHeight))
    var rowWidth = Array<CGFloat>(repeating: 0, count: numRows)
    
    func getMinRow() -> (Int, CGFloat) {
      var minWidth: (Int, CGFloat) = (0, rowWidth[0])
      for (index, width) in rowWidth.enumerated() {
        if width < minWidth.1 {
          minWidth = (index, width)
        }
      }
      return minWidth
    }
    
    for i in 0..<dataProvider.numberOfItems {
      let avaliableHeight = (maxSize.height - CGFloat(rowWidth.count - 1) * 10) / CGFloat(rowWidth.count)
      var cellSize = sizeProvider.size(at: i, data: dataProvider.data(at: i), maxSize: CGSize(width: .infinity, height: avaliableHeight))
      cellSize.height = avaliableHeight
      let (rowIndex, offsetX) = getMinRow()
      rowWidth[rowIndex] += cellSize.width + 10
      let frame = CGRect(origin: CGPoint(x: offsetX, y: CGFloat(rowIndex) * (avaliableHeight + 10)), size: cellSize)
      frames.append(frame)
    }
  }
}
