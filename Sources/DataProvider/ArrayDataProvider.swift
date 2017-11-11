//
//  ArrayDataProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

open class ArrayDataProvider<Data>: CollectionDataProvider<Data> {
  public var data: [Data] {
    didSet {
      setNeedsReload()
    }
  }
  public var identifierMapper: (Int, Data) -> String {
    didSet {
      setNeedsReload()
    }
  }

  public init(data: [Data], identifierMapper: @escaping (Int, Data) -> String = { index, _ in "\(index)" }) {
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
