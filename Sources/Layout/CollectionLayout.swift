//
//  CollectionLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionLayout<Data> {
  open var insets: UIEdgeInsets = .zero
  open var frames: [CGRect] = []
  open var visibleIndexSorter: CollectionVisibleIndexSorter?

  open func layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    frames = []
  }
  
  private var _contentSize: CGSize = .zero
  internal func _layout(collectionSize: CGSize, dataProvider: CollectionDataProvider<Data>, sizeProvider: CollectionSizeProvider<Data>) {
    layout(collectionSize: collectionSize.insets(by: insets), dataProvider: dataProvider, sizeProvider: sizeProvider)
    _contentSize = frames.reduce(CGRect.zero) { (old, item) in
      old.union(item)
    }.size
  }

  open var contentSize: CGSize {
    return _contentSize.insets(by: -insets)
  }

  open func frame(at: Int) -> CGRect {
    return frames[at] + CGPoint(x: insets.left, y: insets.top)
  }

  open func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    let visibleFrame = activeFrame - CGPoint(x: insets.left, y: insets.top)
    if let visibleIndexSorter = visibleIndexSorter {
      return visibleIndexSorter.visibleIndexes(for: visibleFrame)
    }
    var result = Set<Int>()
    for (i, frame) in frames.enumerated() {
      if frame.intersects(visibleFrame) {
        result.insert(i)
      }
    }
    return result
  }

  public init(insets: UIEdgeInsets = .zero) {
    self.insets = insets
  }
}
