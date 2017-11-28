//
//  FloatLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-31.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class FloatLayout<Data>: WrapperLayout<Data> {
  var floatingFrames: [(index: Int, frame: CGRect)] = []
  var isFloated: (Int, CGRect) -> Bool

  public init(rootLayout: CollectionLayout<Data>,
              isFloated: @escaping (Int, CGRect) -> Bool = { index, _ in index % 2 == 0 }) {
    self.isFloated = isFloated
    super.init(rootLayout)
  }

  public override var contentSize: CGSize {
    return rootLayout.contentSize
  }

  override public func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: @escaping (Int, Data, CGSize) -> CGSize) {
    rootLayout.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)
    floatingFrames = (0..<dataProvider.numberOfItems).map {
      (index: $0, frame: rootLayout.frame(at: $0))
    }.filter {
      isFloated($0.0, $0.1)
    }
  }

  var activeFrame: CGRect = .zero
  var topFrameIndex: Int = 0
  public override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    self.activeFrame = activeFrame
    topFrameIndex = floatingFrames.binarySearch { $0.frame.minY < activeFrame.minY } - 1
    if let index = floatingFrames.get(topFrameIndex)?.index, index >= 0 {
      var oldVisible = rootLayout.visibleIndexes(activeFrame: activeFrame)
      if let index = oldVisible.index(of: index) {
        oldVisible.remove(at: index)
      }
      return oldVisible + [index]
    }
    return rootLayout.visibleIndexes(activeFrame: activeFrame)
  }

  public override func frame(at: Int) -> CGRect {
    let superFrame = rootLayout.frame(at: at)
    if superFrame.minY < activeFrame.minY, let index = floatingFrames.get(topFrameIndex)?.index, index == at {
      let pushedY: CGFloat
      if topFrameIndex < floatingFrames.count - 1 {
        pushedY = rootLayout.frame(at: floatingFrames[topFrameIndex + 1].index).minY - superFrame.height
      } else {
        pushedY = activeFrame.maxY - superFrame.height
      }
      return CGRect(origin: CGPoint(x: superFrame.minX, y: min(activeFrame.minY, pushedY)), size: superFrame.size)
    }
    return superFrame
  }
}
