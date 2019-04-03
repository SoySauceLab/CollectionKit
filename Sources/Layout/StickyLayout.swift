//
//  StickyLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-31.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class StickyLayout: WrapperLayout {
  public var isStickyFn: (Int) -> Bool

  var stickyFrames: [(index: Int, frame: CGRect)] = []
  var visibleFrame: CGRect = .zero
  var topFrameIndex: Int = 0

  public init(rootLayout: Layout,
              isStickyFn: @escaping (Int) -> Bool = { $0 % 2 == 0 }) {
    self.isStickyFn = isStickyFn
    super.init(rootLayout)
  }

  public override var contentSize: CGSize {
    return rootLayout.contentSize
  }

  public override func layout(context: LayoutContext) {
    rootLayout.layout(context: context)
    stickyFrames = (0..<context.numberOfItems).filter {
      isStickyFn($0)
    }.map {
      (index: $0, frame: rootLayout.frame(at: $0))
    }
  }

  public override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    self.visibleFrame = visibleFrame
    topFrameIndex = stickyFrames.binarySearch { $0.frame.minY < visibleFrame.minY } - 1
    if let index = stickyFrames.get(topFrameIndex)?.index, index >= 0 {
      var oldVisible = rootLayout.visibleIndexes(visibleFrame: visibleFrame)
      if let index = oldVisible.firstIndex(of: index) {
        oldVisible.remove(at: index)
      }
      return oldVisible + [index]
    }
    return rootLayout.visibleIndexes(visibleFrame: visibleFrame)
  }

  public override func frame(at: Int) -> CGRect {
    let superFrame = rootLayout.frame(at: at)
    if superFrame.minY < visibleFrame.minY, let index = stickyFrames.get(topFrameIndex)?.index, index == at {
      let pushedY: CGFloat
      if topFrameIndex < stickyFrames.count - 1 {
        pushedY = rootLayout.frame(at: stickyFrames[topFrameIndex + 1].index).minY - superFrame.height
      } else {
        pushedY = visibleFrame.maxY - superFrame.height
      }
      return CGRect(origin: CGPoint(x: superFrame.minX, y: min(visibleFrame.minY, pushedY)), size: superFrame.size)
    }
    return superFrame
  }
}
