//
//  FlexLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public enum FlexJustifyContent {
  case start, end, center, spaceBetween, spaceAround, spaceEvenly
}

public enum FlexAlignItem {
  case start, end, center, stretch
}

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

public class FlexLayout<Data>: AxisDependentLayout<Data> {
  public var padding: CGFloat
  public var flex: [String: FlexValue]
  public var alignItems: FlexAlignItem
  public var justifyContent: FlexJustifyContent

  public init(flex: [String: FlexValue] = [:],
              insets: UIEdgeInsets = .zero,
              padding: CGFloat = 0,
              axis: Axis = .vertical,
              justifyContent: FlexJustifyContent = .start,
              alignItems: FlexAlignItem = .start) {
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
                              sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []

    let (sizes, totalPrimary) = getSizes(collectionSize: collectionSize,
                                         dataProvider: dataProvider,
                                         sizeProvider: sizeProvider)

    var offset: CGFloat = 0
    var padding = self.padding
    if totalPrimary < primary(collectionSize) {
      let leftOverPrimaryWithPadding = primary(collectionSize) - totalPrimary
      let leftOverPrimary = leftOverPrimaryWithPadding + self.padding * CGFloat(dataProvider.numberOfItems - 1)
      switch justifyContent {
      case .start:
        break
      case .center:
        offset += leftOverPrimaryWithPadding / 2
      case .end:
        offset += leftOverPrimaryWithPadding
      case .spaceBetween:
        padding = leftOverPrimary / CGFloat(dataProvider.numberOfItems - 1)
      case .spaceAround:
        padding = leftOverPrimary / CGFloat(dataProvider.numberOfItems)
        offset = padding / 2
      case .spaceEvenly:
        padding = leftOverPrimary / CGFloat(dataProvider.numberOfItems + 1)
        offset = padding
      }
    }

    for cellSize in sizes {
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


extension FlexLayout {
  func getSizes(collectionSize: CGSize,
                dataProvider: CollectionDataProvider<Data>,
                sizeProvider: @escaping CollectionSizeProvider<Data>) -> (sizes: [CGSize], totalPrimary: CGFloat) {
    var sizes: [CGSize] = []
    var freezedPrimary = padding * CGFloat(dataProvider.numberOfItems - 1)
    var flexValues: [Int: (FlexValue, CGFloat)] = [:]

    for i in 0..<dataProvider.numberOfItems {
      if let flex = flex[dataProvider.identifier(at: i)] {
        flexValues[i] = (flex, flex.flexBasis)
        sizes.append(.zero)
      } else {
        let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
        sizes.append(size)
        freezedPrimary += primary(size)
      }
    }

    while !flexValues.isEmpty {
      var totalPrimary = freezedPrimary
      for (_, primary) in flexValues.values {
        totalPrimary += primary
      }

      var clampDiff: CGFloat = 0

      // distribute remaining space
      if totalPrimary.rounded() != primary(collectionSize).rounded() {
        // use flexGrow
        let totalFlex = flexValues.values.reduce(0) { $0.0 + $0.1.0.flex }
        let primaryPerFlex: CGFloat = totalFlex > 0 ? (primary(collectionSize) - totalPrimary) / totalFlex : 0
        for (i, (flex, primary)) in flexValues {
          let currentPrimary = (primary + flex.flex * primaryPerFlex)
          let clamped = currentPrimary.clamp(flex.range.lowerBound, flex.range.upperBound)
          clampDiff += clamped - currentPrimary
          flexValues[i] = (flex, currentPrimary)
        }
      }

      func freeze(index: Int, primary: CGFloat) {
        let freezedSize = sizeProvider(index, dataProvider.data(at: index), self.size(primary: primary, secondary: secondary(collectionSize)))
        sizes[index] = self.size(primary: primary, secondary: secondary(freezedSize))
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

    return (sizes, freezedPrimary)
  }
}
