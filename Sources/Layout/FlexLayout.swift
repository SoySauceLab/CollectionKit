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
  var flexBasis: CGFloat
  var range: ClosedRange<CGFloat>

  public init(flex: CGFloat, flexBasis: CGFloat, range: ClosedRange<CGFloat>) {
    self.flex = flex
    self.flexBasis = flexBasis
    self.range = range
  }
  public init(flex: CGFloat = 0, flexBasis: CGFloat = 0, min: CGFloat = 0, max: CGFloat = .infinity) {
    self.init(flex: flex, flexBasis: flexBasis, range: min...max)
  }
}

public class FlexLayout<Data>: HorizontalSimpleLayout<Data> {
  public var spacing: CGFloat
  public var flex: [String: FlexValue]
  public var alignItems: AlignItem
  public var justifyContent: JustifyContent

  public init(flex: [String: FlexValue] = [:],
              spacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start) {
    self.spacing = spacing
    self.flex = flex
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    super.init()
  }

  public override func simpleLayout(collectionSize: CGSize,
                                    dataProvider: CollectionDataProvider<Data>,
                                    sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {

    let (sizes, totalWidth) = getCellSizes(collectionSize: collectionSize,
                                           dataProvider: dataProvider,
                                           sizeProvider: sizeProvider)

    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: collectionSize.width,
                                                               totalPrimary: totalWidth,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: dataProvider.numberOfItems)

    let frames = LayoutHelper.alignItem(alignItems: alignItems,
                                        startingPrimaryOffset: offset, spacing: distributedSpacing,
                                        sizes: sizes, secondaryRange: 0...collectionSize.height)

    return frames
  }
}

extension FlexLayout {

  //swiftlint:disable:next function_body_length cyclomatic_complexity
  func getCellSizes(collectionSize: CGSize,
                    dataProvider: CollectionDataProvider<Data>,
                    sizeProvider: @escaping CollectionSizeProvider<Data>) -> (sizes: [CGSize], totalWidth: CGFloat) {
    var sizes: [CGSize] = []
    let spacings = spacing * CGFloat(dataProvider.numberOfItems - 1)
    var freezedWidth = spacings
    var flexValues: [Int: (FlexValue, CGFloat)] = [:]

    for i in 0..<dataProvider.numberOfItems {
      if let flex = flex[dataProvider.identifier(at: i)] {
        flexValues[i] = (flex, flex.flexBasis)
        sizes.append(.zero)
      } else {
        let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
        sizes.append(size)
        freezedWidth += size.width
      }
    }

    while !flexValues.isEmpty {
      var totalWidth = freezedWidth
      for (_, width) in flexValues.values {
        totalWidth += width
      }

      var clampDiff: CGFloat = 0

      // distribute remaining space
      if totalWidth.rounded() != collectionSize.width.rounded() {
        // use flexGrow
        let totalFlex = flexValues.values.reduce(0) { $0.0 + $0.1.0.flex }
        let widthPerFlex: CGFloat = totalFlex > 0 ? (collectionSize.width - totalWidth) / totalFlex : 0
        for (i, (flex, width)) in flexValues {
          let currentWidth = (width + flex.flex * widthPerFlex)
          let clamped = currentWidth.clamp(flex.range.lowerBound, flex.range.upperBound)
          clampDiff += clamped - currentWidth
          flexValues[i] = (flex, currentWidth)
        }
      }

      func freeze(index: Int, width: CGFloat) {
        let freezedSize = sizeProvider(index, dataProvider.data(at: index),
                                       CGSize(width: width, height: collectionSize.height))
        sizes[index] = CGSize(width: max(width, freezedSize.width), height: freezedSize.height)
        freezedWidth += width
        flexValues[index] = nil
      }

      // freeze flex size
      if clampDiff == 0 {
        // No min/max violation. Freeze all flex values
        for (i, (flex, width)) in flexValues {
          freeze(index: i, width: width.clamp(flex.range.lowerBound, flex.range.upperBound))
        }
      } else if clampDiff > 0 {
        // Freeze all min violation
        for (i, (flex, width)) in flexValues {
          if width <= flex.range.lowerBound {
            freeze(index: i, width: flex.range.lowerBound)
          } else if width > flex.range.upperBound {
            flexValues[i]!.1 = flex.range.upperBound
          }
        }
      } else {
        // Freeze all max violation
        for (i, (flex, width)) in flexValues {
          if width >= flex.range.upperBound {
            freeze(index: i, width: flex.range.upperBound)
          } else if width < flex.range.lowerBound {
            flexValues[i]!.1 = flex.range.lowerBound
          }
        }
      }
    }

    return (sizes, freezedWidth - spacings)
  }
}
