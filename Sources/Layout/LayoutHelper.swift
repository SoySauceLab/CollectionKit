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
  let axis: Axis

  init(axis: Axis) {
    self.axis = axis
  }

  func primary(_ size: CGSize) -> CGFloat {
    return axis == .vertical ? size.height : size.width
  }
  func secondary(_ size: CGSize) -> CGFloat {
    return axis != .vertical ? size.height : size.width
  }
  func primary(_ point: CGPoint) -> CGFloat {
    return axis == .vertical ? point.y : point.x
  }
  func secondary(_ point: CGPoint) -> CGFloat {
    return axis != .vertical ? point.y : point.x
  }
  func size(primary: CGFloat, secondary: CGFloat) -> CGSize {
    return axis == .vertical ? CGSize(width: secondary, height: primary) : CGSize(width: primary, height: secondary)
  }
  func point(primary: CGFloat, secondary: CGFloat) -> CGPoint {
    return axis == .vertical ? CGPoint(x: secondary, y: primary) : CGPoint(x: primary, y: secondary)
  }

  func alignItem<SizeArray: Sequence>(alignItems: AlignItem,
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
        cellFrame = CGRect(origin: point(primary: offset, secondary: secondaryRange.lowerBound), size: cellSize)
      case .end:
        cellFrame = CGRect(origin: point(primary: offset,
                                         secondary: secondaryRange.upperBound - secondary(cellSize)),
                           size: cellSize)
      case .center:
        let secondaryOffset = secondaryRange.lowerBound + (secondaryRange.upperBound - secondaryRange.lowerBound - secondary(cellSize)) / 2
        cellFrame = CGRect(origin: point(primary: offset, secondary: secondaryOffset),
                           size: cellSize)
      case .stretch:
        cellFrame = CGRect(origin: point(primary: offset, secondary: secondaryRange.lowerBound),
                           size: size(primary: primary(cellSize), secondary: secondaryRange.upperBound - secondaryRange.lowerBound))
      }
      frames.append(cellFrame)
      offset += primary(cellSize) + spacing
    }
    return frames
  }

  func distribute(justifyContent: JustifyContent,
                  maxPrimary: CGFloat,
                  totalPrimary: CGFloat,
                  minimunSpacing: CGFloat,
                  numberOfItems: Int) -> (offset: CGFloat, spacing: CGFloat) {
    var offset: CGFloat = 0
    var spacing = minimunSpacing
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
