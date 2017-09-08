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
  public var interitemSpacing: CGFloat

  public init(insets: UIEdgeInsets = .zero,
              lineSpacing: CGFloat = 0,
              interitemSpacing: CGFloat = 0,
              axis: Axis = .vertical) {
    self.lineSpacing = lineSpacing
    self.interitemSpacing = interitemSpacing
    super.init()
    self.axis = axis
    self.insets = insets
  }

  public override func layout(collectionSize: CGSize,
                              dataProvider: CollectionDataProvider<Data>,
                              sizeProvider: @escaping CollectionSizeProvider<Data>) -> [CGRect] {
    var frames: [CGRect] = []
    var primaryOffset: CGFloat = 0
    var secondaryOffset: CGFloat = 0
    var currentMaxPrimary: CGFloat = 0
    for i in 0..<dataProvider.numberOfItems {
      let size = sizeProvider(i, dataProvider.data(at: i), collectionSize)
      if secondaryOffset + secondary(size) > secondary(collectionSize), secondaryOffset != 0 {
        secondaryOffset = 0
        primaryOffset += currentMaxPrimary + lineSpacing
        currentMaxPrimary = 0
      }
      currentMaxPrimary = max(currentMaxPrimary, primary(size))
      let frame = CGRect(origin: point(primary: primaryOffset, secondary: secondaryOffset), size: size)
      frames.append(frame)
      secondaryOffset += secondary(size) + interitemSpacing
    }
    return frames
  }
}
