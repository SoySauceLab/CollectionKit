//
//  CollectionViewProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionViewProvider<Data, View: UIView>  {
  open func view(at: Int) -> View {
    return CollectionReuseViewManager.shared.dequeue(View.self)
  }
  open func update(view: View, with data: Data, at: Int) {
  }
  public init() {}
}

public class ClosureViewProvider<Data, View>: CollectionViewProvider<Data, View> where View: UIView {
  public var viewUpdater: (View, Data, Int) -> Void
  public init(viewUpdater: @escaping (View, Data, Int) -> Void) {
    self.viewUpdater = viewUpdater
    super.init()
  }

  public override func update(view: View, with data: Data, at: Int) {
    viewUpdater(view, data, at)
  }
}
