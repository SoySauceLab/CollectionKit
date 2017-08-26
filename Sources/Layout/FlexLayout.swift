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
    self.init(flex: flex, range: min...max)
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

  private enum ItemState {
    case freezed(CGSize)
    case flex(FlexValue, CGFloat)

    var size: CGSize {
      switch self {
      case .flex:
        fatalError()
      case .freezed(let size):
        return size
      }
    }
  }

  private func totalPrimaryAndFlex(itemStates: [ItemState]) -> (height: CGFloat, flex: CGFloat) {
    var totalPrimary: CGFloat = 0
    var totalFlex: CGFloat = 0

    for state in itemStates {
      switch state {
      case .flex(let flex, let primary):
        totalFlex += flex.flex
        totalPrimary += primary
      case .freezed(let size):
        totalPrimary += primary(size)
      }
    }

    return (totalPrimary, totalFlex)
  }

  public override func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []

    var itemStates: [ItemState] = []

    var allItemFreezed: Bool = true

    for i in 0..<dataProvider.numberOfItems {
      if let flex = flex[dataProvider.identifier(at: i)] {
        itemStates.append(.flex(flex, flex.range.lowerBound))
        allItemFreezed = false
      } else {
        let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
        itemStates.append(.freezed(size))
      }
    }

    while !allItemFreezed {
      allItemFreezed = true

      var (totalPrimary, totalFlex) = self.totalPrimaryAndFlex(itemStates: itemStates)
      totalPrimary += padding * CGFloat(dataProvider.numberOfItems - 1)

      let primaryPerFlex: CGFloat = totalFlex > 0 ? (primary(collectionSize) - totalPrimary) / totalFlex : 0
      var clampDiff: CGFloat = 0

      for i in 0..<itemStates.count {
        if case let .flex(flex, primary) = itemStates[i] {
          let currentPrimary = (primary + flex.flex * primaryPerFlex)
          let clamped = currentPrimary.clamp(flex.range.lowerBound, flex.range.upperBound)
          clampDiff += clamped - currentPrimary
          itemStates[i] = .flex(flex, currentPrimary)
        }
      }

      if clampDiff == 0 {
        for i in 0..<itemStates.count {
          if case let .flex(_, primary) = itemStates[i] {
            let freezedSize = sizeProvider(i, dataProvider.data(at: i), self.size(primary: primary, secondary: secondary(collectionSize)))
            itemStates[i] = .freezed(self.size(primary: primary, secondary: secondary(freezedSize)))
          }
        }
      } else if clampDiff > 0 {
        for i in 0..<itemStates.count {
          if case let .flex(flex, primary) = itemStates[i] {
            if primary < flex.range.lowerBound {
              let primary = flex.range.lowerBound
              let freezedSize = sizeProvider(i, dataProvider.data(at: i), self.size(primary: primary, secondary: secondary(collectionSize)))
              itemStates[i] = .freezed(self.size(primary: primary, secondary: secondary(freezedSize)))
            } else {
              allItemFreezed = false
            }
          }
        }
      } else {
        for i in 0..<itemStates.count {
          if case let .flex(flex, primary) = itemStates[i] {
            if primary > flex.range.upperBound {
              let primary = flex.range.upperBound
              let freezedSize = sizeProvider(i, dataProvider.data(at: i), self.size(primary: primary, secondary: secondary(collectionSize)))
              itemStates[i] = .freezed(self.size(primary: primary, secondary: secondary(freezedSize)))
            } else {
              allItemFreezed = false
            }
          }
        }
      }
    }


    var offset: CGFloat = 0
    //    if totalPrimary < primary(collectionSize), totalFlex == 0 {
    //      switch justifyContent {
    //      case .center:
    //        offset += (primary(collectionSize) - totalPrimary) / 2
    //      case .end:
    //        offset += primary(collectionSize) - totalPrimary
    //      default:
    //        break
    //      }
    //    }

    for state in itemStates {
      let cellSize: CGSize = state.size
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
