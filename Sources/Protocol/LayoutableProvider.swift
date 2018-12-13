//
//  LayoutableProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-13.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

public protocol LayoutableProvider {
  var layout: Layout { get }
  var internalLayout: Layout { get }
  func layoutContext(collectionSize: CGSize) -> LayoutContext
}

extension LayoutableProvider where Self: Provider {
  public var internalLayout: Layout {
    return layout
  }
  public func layout(collectionSize: CGSize) {
    internalLayout.layout(context: layoutContext(collectionSize: collectionSize))
  }
  public func visible(in visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect) {
    return internalLayout.visible(in: visibleFrame)
  }
  public var contentSize: CGSize {
    return internalLayout.contentSize
  }
  public func frame(at: Int) -> CGRect {
    return internalLayout.frame(at: at)
  }
}
