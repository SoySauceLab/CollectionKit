//
//  ClosureLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class Closurelayout: SimpleLayout {
  public var frameProvider: (Int, CGSize) -> CGRect

  public init(frameProvider: @escaping (Int, CGSize) -> CGRect) {
    self.frameProvider = frameProvider
    super.init()
  }

  public override func simpleLayout(context: LayoutContext) -> [CGRect] {
    var frames: [CGRect] = []
    for i in 0..<context.numberOfItems {
      let frame = frameProvider(i, context.collectionSize)
      frames.append(frame)
    }
    return frames
  }
}
