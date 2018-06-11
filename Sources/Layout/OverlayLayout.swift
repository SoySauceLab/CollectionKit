//
//  OverlayLayout.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2017-08-29.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class OverlayLayout: SimpleLayout {
  public override func simpleLayout(context: LayoutContext) -> [CGRect] {
    var frames: [CGRect] = []
    for i in 0..<context.numberOfItems {
      let size = context.size(at: i, collectionSize: context.collectionSize)
      frames.append(CGRect(origin: .zero, size: size))
    }
    return frames
  }
}
