//
//  ArrayDataSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

open class ArrayDataSource<Data>: DataSource<Data> {
  open var data: [Data] {
    didSet {
      setNeedsReload()
    }
  }

  open var identifierSource: IdentifierSource<Data> {
    didSet {
      setNeedsReload()
    }
  }

  public init(data: [Data] = [],
              identifierSource: @escaping IdentifierSource<Data> = defaultIdentifierSource) {
    self.data = data
    self.identifierSource = identifierSource
  }

  open override var numberOfItems: Int {
    return data.count
  }

  open override func identifier(at: Int) -> String {
    return identifierSource(at, data[at])
  }

  open override func data(at: Int) -> Data {
    return data[at]
  }
}
