//
//  SimpleLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-11.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class SimpleLayout<Data>: CollectionLayout<Data> {
  var _contentSize: CGSize = .zero
  public private(set) var frames: [CGRect] = []

  open func simpleLayout(collectionSize: CGSize,
                         dataProvider: CollectionDataProvider<Data>,
                         sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    fatalError("Subclass should provide its own layout")
  }

  open func doneLayout() {

  }

  public final override func layout(collectionSize: CGSize,
                                    dataProvider: CollectionDataProvider<Data>,
                                    sizeProvider: @escaping CollectionSizeProvider<Data>) {
    frames = simpleLayout(collectionSize: collectionSize,
                          dataProvider: dataProvider, sizeProvider: sizeProvider)
    _contentSize = frames.reduce(CGRect.zero) { (old, item) in
      old.union(item)
    }.size
    doneLayout()
  }

  public final override var contentSize: CGSize {
    return _contentSize
  }

  public final override func frame(at: Int) -> CGRect {
    return frames[at]
  }

  open override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    var result = [Int]()
    for (i, frame) in frames.enumerated() {
      if frame.intersects(activeFrame) {
        result.append(i)
      }
    }
    return result
  }
}

open class VerticalSimpleLayout<Data>: SimpleLayout<Data> {
  private var maxFrameLength: CGFloat = 0

  open override func doneLayout() {
    maxFrameLength = frames.max { $0.height < $1.height }?.height ?? 0
  }

  open override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    var index = frames.binarySearch { $0.minY < activeFrame.minY - maxFrameLength }
    var visibleIndexes = [Int]()
    while index < frames.count {
      let frame = frames[index]
      if frame.minY >= activeFrame.maxY {
        break
      }
      if frame.maxY > activeFrame.minY {
        visibleIndexes.append(index)
      }
      index += 1
    }
    return visibleIndexes
  }
}

open class HorizontalSimpleLayout<Data>: SimpleLayout<Data> {
  private var maxFrameLength: CGFloat = 0

  open override func doneLayout() {
    maxFrameLength = frames.max { $0.width < $1.width }?.width ?? 0
  }

  open override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    var index = frames.binarySearch { $0.minX < activeFrame.minX - maxFrameLength }
    var visibleIndexes = [Int]()
    while index < frames.count {
      let frame = frames[index]
      if frame.minX >= activeFrame.maxX {
        break
      }
      if frame.maxX > activeFrame.minX {
        visibleIndexes.append(index)
      }
      index += 1
    }
    return visibleIndexes
  }
}
