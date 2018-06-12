//
//  CollectionDataProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

open class DataSource<Data>: CollectionReloadable {
  open var numberOfItems: Int {
    return 0
  }
  open func data(at: Int) -> Data {
    fatalError()
  }
  open func identifier(at: Int) -> String {
    return "\(at)"
  }
  public init() {}
}
