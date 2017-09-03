//
//  CollectionViewProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionViewProvider<Data, View: UIView> {
  lazy var reuseManager = CollectionReuseViewManager()
  open func view(at: Int) -> View {
    return reuseManager.dequeue(View())
  }
  open func update(view: View, with data: Data, at: Int) {
  }
  public init() {}
}
