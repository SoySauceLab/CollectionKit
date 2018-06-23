//
//  SizeSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public typealias SizeSource<Data> = (Int, Data, CGSize) -> CGSize

public func defaultSizeSource<Data>(at: Int, data: Data, collectionSize: CGSize) -> CGSize {
  return collectionSize
}
