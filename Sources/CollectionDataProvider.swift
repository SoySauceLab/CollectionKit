//
//  CollectionDataProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

open class CollectionDataProvider<Data> {
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

open class ArrayDataProvider<Data>: CollectionDataProvider<Data> {
  public var data: [Data]
  public var identifierMapper: (Int, Data) -> String

  public init(data: [Data], identifierMapper: @escaping (Int, Data) -> String = { "\($0)" }) {
    self.data = data
    self.identifierMapper = identifierMapper
  }

  open override var numberOfItems: Int {
    return data.count
  }
  open override func identifier(at: Int) -> String {
    return identifierMapper(at, data[at])
  }
  open override func data(at: Int) -> Data {
    return data[at]
  }
}
