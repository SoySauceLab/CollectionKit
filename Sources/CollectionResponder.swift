//
//  CollectionResponder.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionResponder {
  open func willReload() {}
  open func didReload() {}
  open func willDrag(cell: UIView, at index:Int) -> Bool { return false }
  open func didDrag(cell: UIView, at index:Int) {}
  open func moveItem(at index: Int, to: Int) -> Bool { return false }
  open func didTap(cell: UIView, index: Int) {}
  public init() {}
}

open class ClosureResponder: CollectionResponder {
  open var canDrag: (UIView, Int) -> Bool = { _, _ in return false }
  open var onMove: (Int, Int) -> Bool = { _, _ in return false }
  open var onTap: (UIView, Int) -> Void = { _, _ in }
  
  public init(canDrag: @escaping (UIView, Int) -> Bool = { _, _ in return false },
              onMove: @escaping (Int, Int) -> Bool = { _, _ in return false },
              onTap: @escaping (UIView, Int) -> Void = { _, _ in }) {
    self.canDrag = canDrag
    self.onMove = onMove
    self.onTap = onTap
  }
  open override func willDrag(cell: UIView, at index:Int) -> Bool {
    return canDrag(cell, index)
  }
  open override func moveItem(at index: Int, to: Int) -> Bool {
    return onMove(index, to)
  }
  open override func didTap(cell: UIView, index: Int) {
    onTap(cell, index)
  }
}
