//
//  CollectionResponder.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionResponder<Data> {
  open func willReload() {}
  open func didReload() {}
  open func willDrag(view: UIView, data: Data, at index:Int) -> Bool { return false }
  open func didDrag(view: UIView, data: Data, at index:Int) {}
  open func moveItem(at index: Int, data: Data, to: Int) -> Bool { return false }
  open func didTap(view: UIView, data: Data, at index: Int) {}
  public init() {}
}

open class ClosureResponder<Data>: CollectionResponder<Data> {
  open var canDrag: (UIView, Data, Int) -> Bool
  open var onMove: (Int, Data, Int) -> Bool
  open var onTap: (UIView, Data, Int) -> Void
  
  public init(canDrag: @escaping (UIView, Data, Int) -> Bool = { _, _, _ in return false },
              onMove: @escaping (Int, Data, Int) -> Bool = { _, _, _ in return false },
              onTap: @escaping (UIView, Data, Int) -> Void = { _, _, _ in }) {
    self.canDrag = canDrag
    self.onMove = onMove
    self.onTap = onTap
  }
  open override func willDrag(view: UIView, data: Data, at index:Int) -> Bool {
    return canDrag(view, data, index)
  }
  open override func moveItem(at index: Int, data: Data, to: Int) -> Bool {
    return onMove(index, data, to)
  }
  open override func didTap(view: UIView, data: Data, at index: Int) {
    onTap(view, data, index)
  }
}
