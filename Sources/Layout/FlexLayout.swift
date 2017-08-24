//
//  FlexLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public enum FlexJustifyContent {
  case start, end, center//, spaceBetween, spaceAround, spaceEvenly
}

public enum FlexAlignItem {
  case start, end, center, stretch
}

public struct FlexValue {
  var flex: CGFloat
  var range: ClosedRange<CGFloat>
  public init(flex: CGFloat, range: ClosedRange<CGFloat>) {
    self.flex = flex
    self.range = range
  }
  public init(flex: CGFloat, min: CGFloat = 0, max: CGFloat = .infinity) {
    self.flex = flex
    self.range = min...max
  }
}

public class FlexLayout<Data>: AxisDependentLayout<Data> {
  public var padding: CGFloat
  public var flex: [String: FlexValue]
  public var alignItems: FlexAlignItem
  public var justifyContent: FlexJustifyContent

  public init(
    flex: [String: FlexValue] = [:],
    insets: UIEdgeInsets = .zero,
    padding: CGFloat = 0,
    axis: Axis = .vertical,
    justifyContent: FlexJustifyContent = .start,
    alignItems: FlexAlignItem = .start
  ) {
    self.padding = padding
    self.flex = flex
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    super.init()
    self.axis = axis
    self.insets = insets
  }


  public override func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []
    var totalHeight: CGFloat = padding * CGFloat(dataProvider.numberOfItems - 1)
    var totalFlex: CGFloat = 0
    for i in 0..<dataProvider.numberOfItems {
      if let flex = flex[dataProvider.identifier(at: i)] {
        totalHeight += flex.range.lowerBound
        totalFlex += flex.flex
      } else {
        let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
        totalHeight += primary(size)
      }
    }

    let heightPerFlex = totalFlex > 0 ? (primary(collectionSize) - totalHeight) / totalFlex : 0

    var offset: CGFloat = 0
    if totalHeight < primary(collectionSize), totalFlex == 0 {
      switch justifyContent {
      case .center:
        offset += (primary(collectionSize) - totalHeight) / 2
      case .end:
        offset += primary(collectionSize) - totalHeight
      default:
        break
      }
    }

    for i in 0..<dataProvider.numberOfItems {
      let cellSize: CGSize
      if let flex = flex[dataProvider.identifier(at: i)] {
        let height = (flex.range.lowerBound + flex.flex * heightPerFlex).clamp(flex.range.lowerBound, flex.range.upperBound)
        let collectionSize = self.size(primary: height, secondary: collectionSize.width)
        cellSize = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      } else {
        cellSize = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      }
      let cellFrame: CGRect
      switch alignItems {
      case .start:
        cellFrame = CGRect(origin: self.point(primary: offset, secondary: 0), size: cellSize)
      case .end:
        cellFrame = CGRect(origin: self.point(primary: offset, secondary: secondary(collectionSize)), size: cellSize)
      case .center:
        cellFrame = CGRect(origin: self.point(primary: offset, secondary: (secondary(collectionSize) - secondary(cellSize)) / 2), size: cellSize)
      case .stretch:
        cellFrame = CGRect(origin: self.point(primary: offset, secondary: 0), size: size(primary: primary(cellSize), secondary: secondary(collectionSize)))
      }
      frames.append(cellFrame)
      offset += primary(cellSize) + padding
    }
    return frames
  }
}
