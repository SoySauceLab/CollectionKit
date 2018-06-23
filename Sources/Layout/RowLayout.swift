//
//  RowLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class RowLayout: HorizontalSimpleLayout {
  public var spacing: CGFloat
  public var fillIdentifiers: Set<String>
  public var alignItems: AlignItem
  public var justifyContent: JustifyContent

  /// always stretch filling item to fill empty space even if sizeSource returns a smaller size
  public var alwaysFillEmptySpaces: Bool = true

  public init(fillIdentifiers: Set<String>,
              spacing: CGFloat = 0,
              justifyContent: JustifyContent = .start,
              alignItems: AlignItem = .start) {
    self.spacing = spacing
    self.fillIdentifiers = fillIdentifiers
    self.justifyContent = justifyContent
    self.alignItems = alignItems
    super.init()
  }

  public convenience init(_ fillIdentifiers: String...,
                          spacing: CGFloat = 0,
                          justifyContent: JustifyContent = .start,
                          alignItems: AlignItem = .start) {
    self.init(fillIdentifiers: Set(fillIdentifiers), spacing: spacing,
              justifyContent: justifyContent, alignItems: alignItems)
  }

  public override func simpleLayout(context: LayoutContext) -> [CGRect] {

    let (sizes, totalWidth) = getCellSizes(context: context)

    let (offset, distributedSpacing) = LayoutHelper.distribute(justifyContent: justifyContent,
                                                               maxPrimary: context.collectionSize.width,
                                                               totalPrimary: totalWidth,
                                                               minimunSpacing: spacing,
                                                               numberOfItems: context.numberOfItems)

    let frames = LayoutHelper.alignItem(alignItems: alignItems,
                                        startingPrimaryOffset: offset, spacing: distributedSpacing,
                                        sizes: sizes, secondaryRange: 0...max(0, context.collectionSize.height))

    return frames
  }
}

extension RowLayout {

  func getCellSizes(context: LayoutContext) -> (sizes: [CGSize], totalWidth: CGFloat) {
    var sizes: [CGSize] = []
    let spacings = spacing * CGFloat(context.numberOfItems - 1)
    var freezedWidth = spacings
    var fillIndexes: [Int] = []

    for i in 0..<context.numberOfItems {
      if fillIdentifiers.contains(context.identifier(at: i)) {
        fillIndexes.append(i)
        sizes.append(.zero)
      } else {
        let size = context.size(at: i, collectionSize: context.collectionSize)
        sizes.append(size)
        freezedWidth += size.width
      }
    }

    let leftOverWidthPerItem: CGFloat = max(0, context.collectionSize.width - freezedWidth) / CGFloat(fillIndexes.count)
    for i in fillIndexes {
      let size = context.size(at: i, collectionSize: CGSize(width: leftOverWidthPerItem,
                                                            height: context.collectionSize.height))
      let width = alwaysFillEmptySpaces ? max(leftOverWidthPerItem, size.width) : size.width
      sizes[i] = CGSize(width: width, height: size.height)
      freezedWidth += sizes[i].width
    }

    return (sizes, freezedWidth - spacings)
  }
}
