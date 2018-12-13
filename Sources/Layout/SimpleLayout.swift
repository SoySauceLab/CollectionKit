//
//  SimpleLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-11.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class SimpleLayout: Layout {
  var _contentSize: CGSize = .zero
  public private(set) var frames: [CGRect] = []

  open func simpleLayout(context: LayoutContext) -> [CGRect] {
    fatalError("Subclass should provide its own layout")
  }

  open func doneLayout() {

  }

  public final override func layout(context: LayoutContext) {
    frames = simpleLayout(context: context)
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

  open override func visible(in visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect) {
    var result = [Int]()
    for (i, frame) in frames.enumerated() {
      if frame.intersects(visibleFrame) {
        result.append(i)
      }
    }
    return (result, visibleFrame)
  }
}

open class VerticalSimpleLayout: SimpleLayout {
  private var maxFrameLength: CGFloat = 0

  open override func doneLayout() {
    maxFrameLength = frames.max { $0.height < $1.height }?.height ?? 0
  }

  open override func visible(in visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect) {
    guard !visibleFrame.isEmptyOrNegative else {
        // When this vertical layout gets called in a
        // section provider with horizontal layout we need
        // to guard here because the optimised index search
        // here doesn't take the X axes into account.
      return ([], visibleFrame)
    }
    var index = frames.binarySearch { $0.minY < visibleFrame.minY - maxFrameLength }
    var visibleIndexes = [Int]()
    while index < frames.count {
      let frame = frames[index]
      if frame.minY >= visibleFrame.maxY {
        break
      }
      if frame.maxY > visibleFrame.minY {
        visibleIndexes.append(index)
      }
      index += 1
    }
    return (visibleIndexes, visibleFrame)
  }
}

open class HorizontalSimpleLayout: SimpleLayout {
  private var maxFrameLength: CGFloat = 0

  open override func doneLayout() {
    maxFrameLength = frames.max { $0.width < $1.width }?.width ?? 0
  }

  open override func visible(in visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect) {
    guard !visibleFrame.isEmptyOrNegative else {
        return ([], visibleFrame)
    }
    var index = frames.binarySearch { $0.minX < visibleFrame.minX - maxFrameLength }
    var visibleIndexes = [Int]()
    while index < frames.count {
      let frame = frames[index]
      if frame.minX >= visibleFrame.maxX {
        break
      }
      if frame.maxX > visibleFrame.minX {
        visibleIndexes.append(index)
      }
      index += 1
    }
    return (visibleIndexes, visibleFrame)
  }
}

extension CGRect {
  /// Returns whether a rectangle has zero or less
  /// width or height, or is a null rectangle.
  var isEmptyOrNegative: Bool {
    return isEmpty || size.width < 0 || size.height < 0
  }
}
