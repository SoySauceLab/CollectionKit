//
//  CollectionLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionLayout<Data> {
  open var insets: UIEdgeInsets = .zero
  open var frames: [CGRect] = []
  open var visibleIndexSorter: CollectionVisibleIndexSorter?

  open func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    frames = []
  }
  
  private var _contentSize: CGSize = .zero
  internal func _layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    layout(collectionSize: collectionSize.insets(by: insets), dataProvider: dataProvider, sizeProvider: sizeProvider)
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
    let visibleFrame = activeFrame - CGPoint(x: insets.left, y: insets.top)
    if let visibleIndexSorter = visibleIndexSorter {
      return visibleIndexSorter.visibleIndexes(for: visibleFrame)
    }
    var result = Set<Int>()
    for (i, frame) in frames.enumerated() {
      if frame.intersects(visibleFrame) {
        result.insert(i)
      }
    }
    return result
  }

  public init(insets: UIEdgeInsets = .zero) {
    self.insets = insets
  }
}

public class Closurelayout<Data>: CollectionLayout<Data> {
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
        var cellSize = sizeProvider.size(at: i, data: dataProvider.data(at: i), collectionSize: CGSize(width: avaliableHeight, height: collectionSize.width))
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
        var cellSize = sizeProvider.size(at: i, data: dataProvider.data(at: i), collectionSize: CGSize(width: collectionSize.width, height: avaliableHeight))
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
      frames.append(frame)
      offset.x += size.width + padding
    }

    visibleIndexSorter = CollectionVerticalVisibleIndexSorter(frames: frames)
  }
}
