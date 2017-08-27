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
  var flexGrow: CGFloat
  var flexShrink: CGFloat
  var range: ClosedRange<CGFloat>

  public init(flexGrow: CGFloat, flexShrink: CGFloat = 0, range: ClosedRange<CGFloat>) {
    self.flexGrow = flexGrow
    self.flexShrink = flexShrink
    self.range = range
  }
  public init(flexGrow: CGFloat = 0, flexShrink: CGFloat = 0, min: CGFloat = 0, max: CGFloat = .infinity) {
    self.init(flexGrow: flexGrow, flexShrink: flexShrink, range: min...max)
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
                              sizeProvider: CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []

    var freezedPrimary = padding * CGFloat(dataProvider.numberOfItems - 1)
    var sizes: [CGSize] = []
    var flexValues: [Int: (FlexValue, CGFloat)] = [:]

    for i in 0..<dataProvider.numberOfItems {
      let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      sizes.append(size)
      if let flex = flex[dataProvider.identifier(at: i)] {
        flexValues[i] = (flex, primary(size))
      } else {
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
      if totalPrimary < primary(collectionSize) {
        // use flexGrow
        let totalFlex = flexValues.values.reduce(0) { $0.0 + $0.1.0.flexGrow }
        let primaryPerFlex: CGFloat = totalFlex > 0 ? (primary(collectionSize) - totalPrimary) / totalFlex : 0
        for (i, (flex, primary)) in flexValues {
          let currentPrimary = (primary + flex.flexGrow * primaryPerFlex)
          let clamped = currentPrimary.clamp(flex.range.lowerBound, flex.range.upperBound)
          clampDiff += clamped - currentPrimary
          flexValues[i] = (flex, currentPrimary)
        }
      } else {
        // use flexShrink
        let totalFlex = flexValues.values.reduce(0) { $0.0 + $0.1.0.flexShrink }
        let primaryPerFlex: CGFloat = totalFlex > 0 ? (primary(collectionSize) - totalPrimary) / totalFlex : 0
        for (i, (flex, primary)) in flexValues {
          let currentPrimary = (primary + flex.flexShrink * primaryPerFlex)
          let clamped = currentPrimary.clamp(flex.range.lowerBound, flex.range.upperBound)
          clampDiff += clamped - currentPrimary
          flexValues[i] = (flex, currentPrimary)
        }
      }

      // freeze flex size
      if clampDiff == 0 {
        // No min/max violation. Freeze all flex values
        for (i, (_, primary)) in flexValues {
          guard primary != self.primary(sizes[i]) else { continue }
          let freezedSize = sizeProvider(i, dataProvider.data(at: i), self.size(primary: primary, secondary: secondary(collectionSize)))
          sizes[i] = self.size(primary: primary, secondary: secondary(freezedSize))
          freezedPrimary += primary
        }
        flexValues.removeAll()
      } else if clampDiff > 0 {
        // Freeze all min violation
        for (i, (flex, primary)) in flexValues where primary <= flex.range.lowerBound {
          let primary = flex.range.lowerBound
          flexValues[i] = nil
          guard primary != self.primary(sizes[i]) else { continue }
          let freezedSize = sizeProvider(i, dataProvider.data(at: i), self.size(primary: primary, secondary: secondary(collectionSize)))
          sizes[i] = self.size(primary: primary, secondary: secondary(freezedSize))
          freezedPrimary += primary
        }
      } else {
        // Freeze all max violation
        for (i, (flex, primary)) in flexValues where primary >= flex.range.upperBound {
          let primary = flex.range.upperBound
          flexValues[i] = nil
          guard primary != self.primary(sizes[i]) else { continue }
          let freezedSize = sizeProvider(i, dataProvider.data(at: i), self.size(primary: primary, secondary: secondary(collectionSize)))
          sizes[i] = self.size(primary: primary, secondary: secondary(freezedSize))
          freezedPrimary += primary
        }
      }
    }


    var offset: CGFloat = 0
    if totalPrimary < primary(collectionSize), totalFlex == 0 {
      switch justifyContent {
      case .center:
        offset += (primary(collectionSize) - totalPrimary) / 2
      case .end:
        offset += primary(collectionSize) - totalPrimary
      default:
        break
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
