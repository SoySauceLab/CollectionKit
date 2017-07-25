//
//  CollectionResponder.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionResponder<Data>: CollectionReloadable {
  public typealias DataProvider = CollectionDataProvider<Data>
  open func willReload() {}
  open func didReload() {}
  open func willDrag(view: UIView, at index:Int, dataProvider: DataProvider) -> Bool { return false }
  open func didDrag(view: UIView, at index:Int, dataProvider: DataProvider) {}
  open func moveItem(at index: Int, to: Int, dataProvider: DataProvider) -> Bool { return false }
  open func didTap(view: UIView, at index: Int, dataProvider: DataProvider) {}
  public init() {}
}

open class ClosureResponder<Data>: CollectionResponder<Data> {
  open var canDrag: (UIView, Int, DataProvider) -> Bool
  open var onMove: (Int, Int, DataProvider) -> Bool
  open var onTap: (UIView, Int, DataProvider) -> Void
  
  public init(canDrag: @escaping (UIView, Int, DataProvider) -> Bool = { _, _, _ in return false },
              onMove: @escaping (Int, Int, DataProvider) -> Bool = { _, _, _ in return false },
              onTap: @escaping (UIView, Int, DataProvider) -> Void = { _, _, _ in }) {
    self.canDrag = canDrag
    self.onMove = onMove
    self.onTap = onTap
  }
  open override func willDrag(view: UIView, at index:Int, dataProvider: DataProvider) -> Bool {
    return canDrag(view, index, dataProvider)
  }
  open override func moveItem(at index: Int, to: Int, dataProvider: DataProvider) -> Bool {
    return onMove(index, to, dataProvider)
  }
  open override func didTap(view: UIView, at index: Int, dataProvider: DataProvider) {
    onTap(view, index, dataProvider)
  }
}
