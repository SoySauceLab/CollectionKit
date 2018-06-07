//
//  LayoutContext.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-07.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

public protocol LayoutContext {
  var collectionSize: CGSize { get }
  var numberOfItems: Int { get }
  func data(at: Int) -> Any
  func identifier(at: Int) -> String
  func size(at: Int, collectionSize: CGSize) -> CGSize
}

struct CollectionProviderLayoutContext<Data>: LayoutContext {
  var collectionSize: CGSize
  var dataProvider: CollectionDataProvider<Data>
  var sizeProvider: CollectionSizeProvider<Data>

  var numberOfItems: Int {
    return dataProvider.numberOfItems
  }
  func data(at: Int) -> Any {
    return dataProvider.data(at: at)
  }
  func identifier(at: Int) -> String {
    return dataProvider.identifier(at: at)
  }
  func size(at: Int, collectionSize: CGSize) -> CGSize {
    return sizeProvider(at, dataProvider.data(at: at), collectionSize)
  }
}
