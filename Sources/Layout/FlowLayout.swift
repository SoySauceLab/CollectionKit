//
//  FlowLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class FlowLayout<Data>: CollectionLayout<Data> {
  public var lineSpacing: CGFloat
  public var interitemSpacing: CGFloat

  public var alignContent: AlignContent
  public var alignItems: AlignItem
  public var justifyContent: JustifyContent

  public init(lineSpacing: CGFloat = 0,
              interitemSpacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start,
              alignContent: AlignContent = .start) {
    self.lineSpacing = lineSpacing
    self.interitemSpacing = interitemSpacing
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    self.alignContent = alignContent
    super.init()
  }

  public override func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []

    let sizes = (0..<dataProvider.numberOfItems).map { sizeProvider($0, dataProvider.data(at: $0), collectionSize) }
    let (totalPrimary, lineData) = distributeLines(sizes: sizes, maxSecondary: collectionSize.width)

    var (offset, spacing) = LayoutHelper.distribute(justifyContent: alignContent,
                                                    maxPrimary: collectionSize.height,
                                                    totalPrimary: totalPrimary,
                                                    minimunSpacing: lineSpacing,
                                                    numberOfItems: lineData.count)

    var index = 0
    for (lineSize, count) in lineData {
      let (linePrimaryOffset, lineInteritemSpacing) =
        LayoutHelper.distribute(justifyContent: justifyContent,
                                    maxPrimary: collectionSize.width,
                                    totalPrimary: lineSize.primary,
                                    minimunSpacing: interitemSpacing,
                                    numberOfItems: count)

      let lineFrames = LayoutHelper.alignItem(alignItems: alignItems,
                                              startingPrimaryOffset: linePrimaryOffset,
                                              spacing: lineInteritemSpacing,
                                              sizes: sizes[index..<(index+count)],
                                              secondaryRange: offset...(offset + lineSize.secondary))

      frames.append(contentsOf: lineFrames)

      offset += lineSize.secondary + spacing
      index += count
    }

    return frames
  }

  func distributeLines(sizes: [CGSize], maxSecondary: CGFloat) ->
    (totalPrimary: CGFloat, lineData: [(lineSize: (primary: CGFloat, secondary: CGFloat), count: Int)]) {
    var lineData: [(lineSize: (primary: CGFloat, secondary: CGFloat), count: Int)] = []
    var currentLineItemCount = 0
    var currentLineTotalPrimary: CGFloat = 0
    var currentLineMaxSecondary: CGFloat = 0
    var totalPrimary: CGFloat = 0
    for size in sizes {
      if currentLineTotalPrimary + size.width > maxSecondary, currentLineItemCount != 0 {
        lineData.append((lineSize: (primary: currentLineTotalPrimary - CGFloat(currentLineItemCount) * interitemSpacing,
                                    secondary: currentLineMaxSecondary),
                         count: currentLineItemCount))
        totalPrimary += currentLineMaxSecondary
        currentLineMaxSecondary = 0
        currentLineTotalPrimary = 0
        currentLineItemCount = 0
      }
      currentLineMaxSecondary = max(currentLineMaxSecondary, size.height)
      currentLineTotalPrimary += size.width + interitemSpacing
      currentLineItemCount += 1
    }
    if currentLineItemCount > 0 {
      lineData.append((lineSize: (primary: currentLineTotalPrimary - CGFloat(currentLineItemCount) * interitemSpacing,
                                  secondary: currentLineMaxSecondary),
                       count: currentLineItemCount))
      totalPrimary += currentLineMaxSecondary
    }
    return (totalPrimary, lineData)
  }
}
