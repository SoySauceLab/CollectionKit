//
//  FlowLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class FlowLayout: VerticalSimpleLayout {
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

  public convenience init(spacing: CGFloat,
                          justifyContent: JustifyContent = .start,
                          alignItems: AlignItem = .start,
                          alignContent: AlignContent = .start) {
    self.init(lineSpacing: spacing,
              interitemSpacing: spacing,
              justifyContent: justifyContent,
              alignItems: alignItems,
              alignContent: alignContent)
  }

  public override func simpleLayout(context: LayoutContext) -> [CGRect] {
    var frames: [CGRect] = []

    let sizes = (0..<context.numberOfItems).map { context.size(at: $0, collectionSize: context.collectionSize) }
    let (totalHeight, lineData) = distributeLines(sizes: sizes, maxWidth: context.collectionSize.width)

    var (yOffset, spacing) = LayoutHelper.distribute(justifyContent: alignContent,
                                                     maxPrimary: context.collectionSize.height,
                                                     totalPrimary: totalHeight,
                                                     minimunSpacing: lineSpacing,
                                                     numberOfItems: lineData.count)

    var index = 0
    for (lineSize, count) in lineData {
      let (xOffset, lineInteritemSpacing) =
        LayoutHelper.distribute(justifyContent: justifyContent,
                                maxPrimary: context.collectionSize.width,
                                totalPrimary: lineSize.width,
                                minimunSpacing: interitemSpacing,
                                numberOfItems: count)

      let lineFrames = LayoutHelper.alignItem(alignItems: alignItems,
                                              startingPrimaryOffset: xOffset,
                                              spacing: lineInteritemSpacing,
                                              sizes: sizes[index..<(index+count)],
                                              secondaryRange: yOffset...(yOffset + lineSize.height))

      frames.append(contentsOf: lineFrames)

      yOffset += lineSize.height + spacing
      index += count
    }

    return frames
  }

  func distributeLines(sizes: [CGSize], maxWidth: CGFloat) ->
    (totalHeight: CGFloat, lineData: [(lineSize: CGSize, count: Int)]) {
    var lineData: [(lineSize: CGSize, count: Int)] = []
    var currentLineItemCount = 0
    var currentLineWidth: CGFloat = 0
    var currentLineMaxHeight: CGFloat = 0
    var totalHeight: CGFloat = 0
    for size in sizes {
      if currentLineWidth + size.width > maxWidth, currentLineItemCount != 0 {
        lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                          height: currentLineMaxHeight),
                         count: currentLineItemCount))
        totalHeight += currentLineMaxHeight
        currentLineMaxHeight = 0
        currentLineWidth = 0
        currentLineItemCount = 0
      }
      currentLineMaxHeight = max(currentLineMaxHeight, size.height)
      currentLineWidth += size.width + interitemSpacing
      currentLineItemCount += 1
    }
    if currentLineItemCount > 0 {
      lineData.append((lineSize: CGSize(width: currentLineWidth - CGFloat(currentLineItemCount) * interitemSpacing,
                                        height: currentLineMaxHeight),
                       count: currentLineItemCount))
      totalHeight += currentLineMaxHeight
    }
    return (totalHeight, lineData)
  }
}
