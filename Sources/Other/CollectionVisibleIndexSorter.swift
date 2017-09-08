//
//  CollectionVisibleIndexesManager.swift
//  CollectionView
//
//  Created by Luke on 3/20/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

extension Collection {
  /// Finds such index N that predicate is true for all elements up to
  /// but not including the index N, and is false for all elements
  /// starting with index N.
  /// Behavior is undefined if there is no such N.
  func binarySearch(predicate: (Iterator.Element) -> Bool) -> Index {
    var low = startIndex
    var high = endIndex
    while low != high {
      let mid = index(low, offsetBy: distance(from: low, to: high)/2)
      if predicate(self[mid]) {
        low = index(after: mid)
      } else {
        high = mid
      }
    }
    return low
  }
}

public protocol CollectionVisibleIndexSorter {
  func visibleIndexes(for rect: CGRect) -> [Int]
}

public class CollectionVerticalVisibleIndexSorter: CollectionVisibleIndexSorter {
  var frames: [CGRect]
  var maxFrameLength: CGFloat

  public init(frames: [CGRect]) {
    self.frames = frames
    maxFrameLength = frames.max { $0.0.height < $0.1.height }?.height ?? 0
  }

  public func visibleIndexes(for rect: CGRect) -> [Int] {
    var index = frames.binarySearch { $0.minY < rect.minY - maxFrameLength }
    var visibleIndexes = [Int]()
    while index < frames.count {
      let frame = frames[index]
      if frame.minY > rect.maxY {
        break
      }
      if frame.maxY >= rect.minY {
        visibleIndexes.append(index)
      }
      index += 1
    }
    return visibleIndexes
  }
}

public class CollectionHorizontalVisibleIndexSorter: CollectionVisibleIndexSorter {
  var frames: [CGRect]
  var maxFrameLength: CGFloat

  public init(frames: [CGRect]) {
    self.frames = frames
    maxFrameLength = frames.max { $0.0.width < $0.1.width }?.width ?? 0
  }

  public func visibleIndexes(for rect: CGRect) -> [Int] {
    var index = frames.binarySearch { $0.minX < rect.minX - maxFrameLength }
    var visibleIndexes = [Int]()
    while index < frames.count {
      let frame = frames[index]
      if frame.minX > rect.maxX {
        break
      }
      if frame.maxX >= rect.minX {
        visibleIndexes.append(index)
      }
      index += 1
    }
    return visibleIndexes
  }
}
