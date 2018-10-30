//
//  ClosureDataSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

open class ClosureDataSource<Data>: DataSource<Data> {

  open var getter: () -> [Data] {
    didSet {
      setNeedsReload()
    }
  }

  open var identifierMapper: IdentifierMapperFn<Data> {
    didSet {
      setNeedsReload()
    }
  }

  public init(getter: @escaping () -> [Data],
              identifierMapper: @escaping IdentifierMapperFn<Data> = { index, _ in "\(index)" }) {
    self.getter = getter
    self.identifierMapper = identifierMapper
  }

  open override var numberOfItems: Int {
    return getter().count
  }

  open override func identifier(at: Int) -> String {
    return identifierMapper(at, getter()[at])
  }

  open override func data(at: Int) -> Data {
    return getter()[at]
  }
}
