//
//  MutableArrayDataProvider.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-05.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import CollectionKit

class MutableArrayDataProvider<Data>: ArrayDataProvider<Data> {
  func append(data: Data) {
    self.data.append(data)
  }

  @discardableResult func remove(at: Int) -> Data {
    return self.data.remove(at: at)
  }
}
