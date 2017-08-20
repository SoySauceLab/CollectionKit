//
//  EquatableTuple.swift
//  CollectionKit
//
//  Created by yansong li on 2017-08-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

public struct HashableTuple<S: Hashable, T> {
  
  var source: S
  var info: T
  
  init(source: S, info: T) {
    self.source = source
    self.info = info
  }
}

extension HashableTuple: Hashable {
  
  public var hashValue: Int {
    return source.hashValue
  }
  
  public static func == (lhs: HashableTuple, rhs: HashableTuple) -> Bool {
    return lhs.source == rhs.source
  }
}
