//
//  CollectionVisibleIndexesManager.swift
//  CollectionView
//
//  Created by Luke on 3/20/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

class CollectionLinearVisibleIndexesManager {
  var minToIndexes: [(CGFloat, Int)] = []
  var maxToIndexes: [(CGFloat, Int)] = []

  var lastMin: CGFloat = 0
  var lastMax: CGFloat = 0

  var minIndex: Int = 0
  var maxIndex: Int = -1

  public func reload(minToIndexes:[(CGFloat, Int)], maxToIndexes:[(CGFloat, Int)]) {
    self.minToIndexes = minToIndexes.sorted { left, right in
      return left.0 < right.0
    }
    self.maxToIndexes = maxToIndexes.sorted { left, right in
      return left.0 < right.0
    }

    // assign a value that doesn't contain any visible indexes
    lastMin = (minToIndexes.first?.0 ?? 0) - 1
    lastMax = lastMin
    minIndex = 0
    maxIndex = self.maxToIndexes.count - 1
  }

  public func visibleIndexes(min:CGFloat, max:CGFloat) -> ([Int], [Int]) {
    var inserted:[Int] = []
    var removed:[Int] = []
    if (max > lastMax) {
      while minIndex < minToIndexes.count, minToIndexes[minIndex].0 < max {
        inserted.append(minToIndexes[minIndex].1)
        minIndex += 1
      }
    } else {
      while minIndex > 0, minToIndexes[minIndex-1].0 > max {
        removed.append(minToIndexes[minIndex-1].1)
        minIndex -= 1
      }
    }

    if (min > lastMin) {
      while maxIndex < maxToIndexes.count - 1, maxToIndexes[maxIndex+1].0 < min {
        removed.append(maxToIndexes[maxIndex+1].1)
        maxIndex += 1
      }
    } else {
      while maxIndex >= 0, maxToIndexes[maxIndex].0 > min {
        inserted.append(maxToIndexes[maxIndex].1)
        maxIndex -= 1
      }
    }

    lastMax = max
    lastMin = min
    return (inserted, removed)
  }

  public init() {}
}

class CollectionVisibleIndexesManager {
  var verticalVisibleIndexManager = CollectionLinearVisibleIndexesManager()
  var horizontalVisibleIndexManager = CollectionLinearVisibleIndexesManager()

  var frames:[CGRect] = []
  var visibleIndexes = Set<Int>()

  func reload(with frames:[CGRect]) {
    self.frames = frames
    let flattened: [(Int, CGRect)] = Array(frames.enumerated())

    verticalVisibleIndexManager.reload(minToIndexes: flattened.map({ return ($0.1.minY, $0.0) }),
                                       maxToIndexes: flattened.map({ return ($0.1.maxY, $0.0) }))

    horizontalVisibleIndexManager.reload(minToIndexes: flattened.map({ return ($0.1.minX, $0.0) }),
                                         maxToIndexes: flattened.map({ return ($0.1.maxX, $0.0) }))
    visibleIndexes.removeAll()
  }

  func frame(at index: Int, isVisibleIn rect:CGRect) -> Bool {
    return rect.intersects(frames[index])
  }

  func visibleIndexes(for rect:CGRect) -> Set<Int> {
    let (vInserted, vRemoved) = verticalVisibleIndexManager.visibleIndexes(min: rect.minY, max: rect.maxY)
    let (hInserted, hRemoved) = horizontalVisibleIndexManager.visibleIndexes(min: rect.minX, max: rect.maxX)

    // Ideally we just do a intersection between horizontal visible indexes & vertical visible indexes
    // However, perform intersections on sets is expansive in some cases. 
    // for example: all the cells are horizontally visible in a vertical scroll view.
    // Therefore, everytime horizontal visible indexes is equal to all indexes. Doing an interaction 
    // between N elements sets will make this function O(n) everytime.
    // We want to target O(1) for subsequent calculation. O(nlogn) for the initial calculation.
    //
    // instead we do the following:
    //   calculate diff in visible indexes from each axis
    //   for all the inserted ones, we check if it is within rect
    //   for all the removed ones, we remove it directly

    for index in vInserted {
      if frame(at: index, isVisibleIn: rect) {
        visibleIndexes.insert(index)
      }
    }
    for index in hInserted {
      if frame(at: index, isVisibleIn: rect) {
        visibleIndexes.insert(index)
      }
    }
    for index in vRemoved {
      visibleIndexes.remove(index)
    }
    for index in hRemoved {
      visibleIndexes.remove(index)
    }
    return visibleIndexes
  }
}
