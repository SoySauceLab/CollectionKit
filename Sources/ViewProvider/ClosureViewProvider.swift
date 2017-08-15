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

  public init(viewUpdater: @escaping (View, Data, Int) -> Void) {
    self.viewUpdater = viewUpdater
    super.init()
  }

  public override func update(view: View, with data: Data, at: Int) {
    viewUpdater(view, data, at)
  }
}
