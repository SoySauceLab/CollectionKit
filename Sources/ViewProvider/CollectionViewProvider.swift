//
//  CollectionViewProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionViewProvider<Data, View: UIView> {
  public private(set) lazy var reuseManager = CollectionReuseViewManager()

  /// Should return a new view for the given data and index
  open func view(data: Data, index: Int) -> View {
    let view = reuseManager.dequeue(View())
    update(view: view, data: data, index: index)
    return view
  }

  /// Should update the given view with the provided data and index
  open func update(view: View, data: Data, index: Int) {
  }

  public init() {}
}
