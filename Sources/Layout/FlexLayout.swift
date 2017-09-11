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

public class FlexLayout<Data>: CollectionLayout<Data> {
  public var padding: CGFloat
  public var flex: [String: FlexValue]
  public var alignItems: AlignItem
  public var justifyContent: JustifyContent

  public init(flex: [String: FlexValue] = [:],
              padding: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start) {
    self.padding = padding
    self.flex = flex
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    super.init()
  }

  public override func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {

    let (sizes, totalPrimary) = getCellSizes(collectionSize: collectionSize,
                                             dataProvider: dataProvider,
                                             sizeProvider: sizeProvider)

    let (offset, spacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                    maxPrimary: collectionSize.width,
                                                    totalPrimary: totalPrimary,
                                                    minimunSpacing: padding,
                                                    numberOfItems: dataProvider.numberOfItems)

    let frames = LayoutHelper.alignItem(alignItems: alignItems,
                                        startingPrimaryOffset: offset, spacing: spacing,
                                        sizes: sizes, secondaryRange: 0...collectionSize.height)

    return frames
  }
}

extension FlexLayout {

  //swiftlint:disable:next function_body_length cyclomatic_complexity
  func getCellSizes(collectionSize: CGSize,
                    dataProvider: CollectionDataProvider<Data>,
                    sizeProvider: @escaping CollectionSizeProvider<Data>) -> (sizes: [CGSize], totalPrimary: CGFloat) {
    var sizes: [CGSize] = []
    let paddings = padding * CGFloat(dataProvider.numberOfItems - 1)
    var freezedPrimary = paddings
    var flexValues: [Int: (FlexValue, CGFloat)] = [:]

    for i in 0..<dataProvider.numberOfItems {
      if let flex = flex[dataProvider.identifier(at: i)] {
        flexValues[i] = (flex, flex.flexBasis)
        sizes.append(.zero)
      } else {
        let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
        sizes.append(size)
        freezedPrimary += size.width
      }
    }

    while !flexValues.isEmpty {
      var totalPrimary = freezedPrimary
      for (_, primary) in flexValues.values {
        totalPrimary += primary
      }

      var clampDiff: CGFloat = 0

      // distribute remaining space
      if totalPrimary.rounded() != collectionSize.width.rounded() {
        // use flexGrow
        let totalFlex = flexValues.values.reduce(0) { $0.0 + $0.1.0.flex }
        let primaryPerFlex: CGFloat = totalFlex > 0 ? (collectionSize.width - totalPrimary) / totalFlex : 0
        for (i, (flex, primary)) in flexValues {
          let currentPrimary = (primary + flex.flex * primaryPerFlex)
          let clamped = currentPrimary.clamp(flex.range.lowerBound, flex.range.upperBound)
          clampDiff += clamped - currentPrimary
          flexValues[i] = (flex, currentPrimary)
        }
      }

      func freeze(index: Int, primary: CGFloat) {
        let freezedSize = sizeProvider(index, dataProvider.data(at: index),
                                       CGSize(width: primary, height: collectionSize.height))
        sizes[index] = CGSize(width: primary, height: freezedSize.height)
        freezedPrimary += primary
        flexValues[index] = nil
      }

      // freeze flex size
      if clampDiff == 0 {
        // No min/max violation. Freeze all flex values
        for (i, (flex, primary)) in flexValues {
          freeze(index: i, primary: primary.clamp(flex.range.lowerBound, flex.range.upperBound))
        }
      } else if clampDiff > 0 {
        // Freeze all min violation
        for (i, (flex, primary)) in flexValues {
          if primary <= flex.range.lowerBound {
            freeze(index: i, primary: flex.range.lowerBound)
          } else if primary > flex.range.upperBound {
            flexValues[i]!.1 = flex.range.upperBound
          }
        }
      } else {
        // Freeze all max violation
        for (i, (flex, primary)) in flexValues {
          if primary >= flex.range.upperBound {
            freeze(index: i, primary: flex.range.upperBound)
          } else if primary < flex.range.lowerBound {
            flexValues[i]!.1 = flex.range.lowerBound
          }
        }
      }
    }

    return (sizes, freezedPrimary - paddings)
  }
}
