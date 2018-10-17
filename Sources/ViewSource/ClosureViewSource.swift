//
//  ClosureViewSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public typealias ViewUpdaterFn<Data, View> = (View, Data, Int) -> Void
public typealias ViewGeneratorFn<Data, View> = (Data, Int) -> View

public class ClosureViewSource<Data, View>: ViewSource<Data, View> where View: UIView {
  public var viewGenerator: ViewGeneratorFn<Data, View>?
  public var viewUpdater: ViewUpdaterFn<Data, View>

  public init(viewGenerator: ViewGeneratorFn<Data, View>? = nil,
              viewUpdater: @escaping ViewUpdaterFn<Data, View>) {
    self.viewGenerator = viewGenerator
    self.viewUpdater = viewUpdater
    super.init()
  }

  public override func update(view: View, data: Data, index: Int) {
    viewUpdater(view, data, index)
  }

  public override func view(data: Data, index: Int) -> View {
    if let viewGenerator = viewGenerator {
      let view = reuseManager.dequeue(viewGenerator(data, index))
      update(view: view, data: data, index: index)
      return view
    } else {
      return super.view(data: data, index: index)
    }
  }
}
