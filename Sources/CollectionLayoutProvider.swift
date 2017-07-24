//
//  CollectionLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionSizeProvider<Data> {
  open func size(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
    return CGSize(width: 50, height: 50)
  }
  public init() {}
}

open class ClosureSizeProvider<Data>: CollectionSizeProvider<Data> {
  public var sizeProvider: (Int, Data, CGSize) -> CGSize

  public init(sizeProvider: @escaping (Int, Data, CGSize) -> CGSize = { _,_,_ in return .zero }) {
    self.sizeProvider = sizeProvider
  }
  
  open override func size(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
    return self.sizeProvider(at, data, collectionSize)
  }
}

open class CollectionLayout<Data> {
  private let visibleIndexesManager = CollectionVisibleIndexesManager()

  open var insets: UIEdgeInsets = .zero
  open var frames: [CGRect] = []
  open func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    frames = []
  }
  
  private var _contentSize: CGSize = .zero
  internal func _layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    layout(collectionSize: collectionSize.insets(by: insets), dataProvider: dataProvider, sizeProvider: sizeProvider)
    visibleIndexesManager.reload(with: frames)
    _contentSize = frames.reduce(CGRect.zero) { (old, item) in
      old.union(item)
    }.size
  }

  open var contentSize: CGSize {
    return _contentSize.insets(by: -insets)
  }
  open func frame(at: Int) -> CGRect {
    return frames[at] + CGPoint(x: insets.left, y: insets.top)
  }
  open func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    return visibleIndexesManager.visibleIndexes(for: activeFrame - CGPoint(x: insets.left, y: insets.top))
  }
  public init(insets: UIEdgeInsets = .zero) {
    self.insets = insets
  }
}

public class ClosureLayoutProvider<Data>: CollectionLayout<Data> {
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

public class HorizontalWaterfallLayoutProvider<Data>: CollectionLayout<Data> {
  public var prefferedRowHeight: CGFloat
  private var numRows = 2
  private var rowWidth: [CGFloat] = [0, 0]
  private var maxSize = CGSize.zero

  public init(prefferedRowHeight: CGFloat  = 180, insets: UIEdgeInsets = .zero) {
    self.prefferedRowHeight = prefferedRowHeight
    super.init(insets: insets)
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
      var cellSize = sizeProvider.size(at: i, data: dataProvider.data(at: i), collectionSize: CGSize(width: collectionSize.width, height: avaliableHeight))
      cellSize.height = avaliableHeight
      let (rowIndex, offsetX) = getMinRow()
      rowWidth[rowIndex] += cellSize.width + 10
      let frame = CGRect(origin: CGPoint(x: offsetX, y: CGFloat(rowIndex) * (avaliableHeight + 10)), size: cellSize)
      frames.append(frame)
    }
  }
}

public class FlowLayout<Data>: CollectionLayout<Data> {
  var padding: CGFloat
  
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
      let size = sizeProvider.size(at: i, data: dataProvider.data(at: i), collectionSize: collectionSize)
      if offset.x + size.width > collectionSize.width, offset.x != 0 {
        offset.x = 0
        offset.y += currentRowMaxHeight + padding
        currentRowMaxHeight = 0
      }
      currentRowMaxHeight = max(currentRowMaxHeight, size.height)
      let frame = CGRect(origin: offset, size: size)
//      print(i, type(of: dataProvider.data(at: i)), frame)
      frames.append(frame)
      offset.x += size.width + padding
    }
  }
}
