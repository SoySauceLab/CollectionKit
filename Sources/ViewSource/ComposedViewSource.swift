//
//  ComposedViewSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-06.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

public class ComposedViewSource<Data>: ViewSource<Data, UIView> {
  public var viewProviderSelector: (Data) -> AnyViewSource

  public init(viewProviderSelector: @escaping (Data) -> AnyViewSource) {
    self.viewProviderSelector = viewProviderSelector
  }

  public override func update(view: UIView, data: Data, index: Int) {
    viewProviderSelector(data).anyUpdate(view: view, data: data, index: index)
  }

  public override func view(data: Data, index: Int) -> UIView {
    return viewProviderSelector(data).anyView(data: data, index: index)
  }
}
