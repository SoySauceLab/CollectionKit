//
//  ClosureViewProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class ClosureViewProvider<Data, View>: CollectionViewProvider<Data, View> where View: UIView {
  public var viewUpdater: (View, Data, Int) -> Void
  public var viewGenerator: (() -> View)?

  public init(viewGenerator: (() -> View)? = nil, viewUpdater: @escaping (View, Data, Int) -> Void) {
    self.viewGenerator = viewGenerator
    self.viewUpdater = viewUpdater
    super.init()
  }

  public override func update(view: View, data: Data, index: Int) {
    viewUpdater(view, data, index)
  }

  public override func view(data:Data, index: Int) -> View {
    if let viewGenerator = viewGenerator {
      let view = reuseManager.dequeue(viewGenerator())
      update(view: view, data: data, index: index)
      return view
    } else {
      return super.view(data: data, index: index)
    }
  }
}
