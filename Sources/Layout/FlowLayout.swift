//
//  FlowLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class FlowLayout<Data>: AxisDependentLayout<Data> {
  public var lineSpacing: CGFloat
  public var minimuminteritemSpacing: CGFloat

  public init(insets: UIEdgeInsets = .zero,
              lineSpacing: CGFloat = 0,
              minimuminteritemSpacing: CGFloat = 0,
              axis: Axis = .vertical) {
    self.lineSpacing = lineSpacing
    self.minimuminteritemSpacing = minimuminteritemSpacing
    super.init()
    self.axis = axis
    self.insets = insets
  }

  public override func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    guard dataProvider.numberOfItems > 0 else {
      return []
    }
    var frames: [CGRect] = []
    var primaryOffset: CGFloat = 0
    var secondaryOffset: CGFloat = 0
    var currentMaxPrimary: CGFloat = 0
    var i = 0
    while i < dataProvider.numberOfItems {
      var currentFitSizes: [CGSize] = []
      for j in i..<dataProvider.numberOfItems {
        let size = sizeProvider(j, dataProvider.data(at: j), collectionSize)
        if secondaryOffset + secondary(size) > secondary(collectionSize) {
          break
        }
        currentFitSizes.append(size)
        secondaryOffset += secondary(size) + minimuminteritemSpacing
        currentMaxPrimary = max(currentMaxPrimary, primary(size))
      }
      if currentFitSizes.count <= 1 {
        let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
        let frame = CGRect(origin: point(primary: primaryOffset, secondary: 0), size: size)
        frames.append(frame)
        primaryOffset += (primary(size) + lineSpacing)
        primaryOffset = CGFloat.floorToScale(primaryOffset)
        i += 1
      } else {
        let itemSecondary = currentFitSizes.reduce(0) {
          $0 + secondary($1)
        }
        let space = (secondary(collectionSize) - itemSecondary) / CGFloat(currentFitSizes.count - 1)
        secondaryOffset = 0
        currentFitSizes.forEach {
          let frame = CGRect(origin: point(primary: primaryOffset, secondary: secondaryOffset),
                             size: $0)
          secondaryOffset += secondary($0) + space
          secondaryOffset = CGFloat.floorToScale(secondaryOffset)
          frames.append(frame)
        }
        primaryOffset += currentMaxPrimary + lineSpacing
        primaryOffset = CGFloat.floorToScale(primaryOffset)
        i += currentFitSizes.count
      }
      currentMaxPrimary = 0
      secondaryOffset = 0
    }
    return frames
  }
}
