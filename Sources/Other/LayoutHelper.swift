//
//  LayoutHelper.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public enum JustifyContent {
  case start, end, center, spaceBetween, spaceAround, spaceEvenly
}

public typealias AlignContent = JustifyContent

public enum AlignItem {
  case start, end, center, stretch
}

struct LayoutHelper {

  static func alignItem<SizeArray: Sequence>(alignItems: AlignItem,
                                             startingPrimaryOffset: CGFloat,
                                             spacing: CGFloat,
                                             sizes: SizeArray,
                                             secondaryRange: ClosedRange<CGFloat>)
    -> [CGRect] where SizeArray.Iterator.Element == CGSize {
    var frames: [CGRect] = []
    var offset = startingPrimaryOffset
    for cellSize in sizes {
      let cellFrame: CGRect
      switch alignItems {
      case .start:
        cellFrame = CGRect(origin: CGPoint(x: offset, y: secondaryRange.lowerBound), size: cellSize)
      case .end:
        cellFrame = CGRect(origin: CGPoint(x: offset,
                                           y: secondaryRange.upperBound - cellSize.height),
                           size: cellSize)
      case .center:
        let secondaryOffset = secondaryRange.lowerBound +
          (secondaryRange.upperBound - secondaryRange.lowerBound - cellSize.height) / 2
        cellFrame = CGRect(origin: CGPoint(x: offset, y: secondaryOffset),
                           size: cellSize)
      case .stretch:
        cellFrame = CGRect(origin: CGPoint(x: offset, y: secondaryRange.lowerBound),
                           size: CGSize(width: cellSize.width,
                                        height: secondaryRange.upperBound - secondaryRange.lowerBound))
      }
      frames.append(cellFrame)
      offset += cellSize.width + spacing
    }
    return frames
  }

  static func distribute(justifyContent: JustifyContent,
                         maxPrimary: CGFloat,
                         totalPrimary: CGFloat,
                         minimunSpacing: CGFloat,
                         numberOfItems: Int) -> (offset: CGFloat, spacing: CGFloat) {
    var offset: CGFloat = 0
    var spacing = minimunSpacing
    guard numberOfItems > 0 else { return (offset, spacing) }
    if totalPrimary + CGFloat(numberOfItems - 1) * minimunSpacing < maxPrimary {
      let leftOverPrimary = maxPrimary - totalPrimary
      switch justifyContent {
      case .start:
        break
      case .center:
        offset += (leftOverPrimary - minimunSpacing * CGFloat(numberOfItems - 1)) / 2
      case .end:
        offset += (leftOverPrimary - minimunSpacing * CGFloat(numberOfItems - 1))
      case .spaceBetween:
        guard numberOfItems > 1 else { break }
        spacing = leftOverPrimary / CGFloat(numberOfItems - 1)
      case .spaceAround:
        spacing = leftOverPrimary / CGFloat(numberOfItems)
        offset = spacing / 2
      case .spaceEvenly:
        spacing = leftOverPrimary / CGFloat(numberOfItems + 1)
        offset = spacing
      }
    }
    return (offset, spacing)
  }
}
