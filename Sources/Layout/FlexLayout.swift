//
//  FlexLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

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

public class FlexLayout<Data>: CollectionLayout<Data> {
  public var padding: CGFloat
  public var axis: UILayoutConstraintAxis
  public var flex: [String: FlexValue]

  public init(flex: [String: FlexValue], insets: UIEdgeInsets = .zero, padding: CGFloat = 0, axis: UILayoutConstraintAxis = .vertical) {
    self.padding = padding
    self.flex = flex
    self.axis = axis
    super.init()
    self.insets = insets
  }

  public override func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    super.layout(collectionSize: collectionSize, dataProvider: dataProvider, sizeProvider: sizeProvider)

    var totalHeight: CGFloat = padding * CGFloat(dataProvider.numberOfItems - 1)
    var totalFlex: CGFloat = 0
    for i in 0..<dataProvider.numberOfItems {
      if let flex = flex[dataProvider.identifier(at: i)] {
        totalHeight += flex.range.lowerBound
        totalFlex += flex.flex
      } else {
        let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
        totalHeight += axis == .vertical ? size.height : size.width
      }
    }

    let heightPerFlex = totalFlex > 0 ? ((axis == .vertical ? collectionSize.height : collectionSize.width) - totalHeight) / totalFlex : 0

    var offset: CGFloat = 0
    for i in 0..<dataProvider.numberOfItems {
      let size: CGSize
      if let flex = flex[dataProvider.identifier(at: i)] {
        let height = (flex.range.lowerBound + flex.flex * heightPerFlex).clamp(flex.range.lowerBound, flex.range.upperBound)
        let collectionSize = axis == .vertical ? CGSize(width: collectionSize.width, height: height) : CGSize(width: height, height: collectionSize.height)
        size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      } else {
        size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      }
      let frame = CGRect(origin: (axis == .vertical ? CGPoint(x: 0, y: offset) : CGPoint(x: offset, y: 0)), size: size)
      frames.append(frame)
      offset += (axis == .vertical ? size.height : size.width) + padding
    }

    visibleIndexSorter = axis == .vertical ? CollectionVerticalVisibleIndexSorter(frames: frames) : CollectionHorizontalVisibleIndexSorter(frames: frames)
  }
}
