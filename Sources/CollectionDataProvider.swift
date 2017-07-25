//
//  CollectionDataProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import Foundation

open class CollectionDataProvider<Data>: CollectionReloadable {
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

open class ClosureDataProvider<Data>: CollectionDataProvider<Data> {
  public var getter: () -> [Data] {
    didSet {
      setNeedsReload()
    }
  }
  public var identifierMapper: (Int, Data) -> String {
    didSet {
      setNeedsReload()
    }
  }
  
  public init(getter: @escaping () -> [Data], identifierMapper: @escaping (Int, Data) -> String = { "\($0)" }) {
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
