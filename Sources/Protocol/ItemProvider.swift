//
//  ItemProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-13.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

public protocol ItemProvider: Provider {
  func view(at: Int) -> UIView
  func update(view: UIView, at: Int)

  func didTap(view: UIView, at: Int)
}

extension ItemProvider {
  public func flattenedProvider() -> ItemProvider {
    return self
  }
}
