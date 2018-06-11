//
//  AnyCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol BaseCollectionProvider {
  var identifier: String? { get }

  // data
  var numberOfItems: Int { get }
  func identifier(at: Int) -> String

  // layout
  func layout(collectionSize: CGSize)

  func visibleIndexes(visibleFrame: CGRect) -> [Int]
  var contentSize: CGSize { get }
  func frame(at: Int) -> CGRect

  // event
  func willReload()
  func didReload()

  func presenter(at: Int) -> CollectionPresenter?

  // determines if a context belongs to current provider
  func hasReloadable(_ reloadable: CollectionReloadable) -> Bool

  func flattenedProvider() -> ViewSource
}

public protocol SectionSource: BaseCollectionProvider {
  func section(at: Int) -> AnyCollectionProvider?
}

public protocol ViewSource: BaseCollectionProvider {
  func view(at: Int) -> UIView
  func update(view: UIView, at: Int)

  func didTap(view: UIView, at: Int)
}

public typealias AnyCollectionProvider = BaseCollectionProvider & CollectionReloadable

extension BaseCollectionProvider {
  public func flattenedProvider() -> ViewSource {
    fatalError("""
      AnyCollectionProvider shouldn't be used by itself,
      please use either ComposedCollectionProvider or ViewOnlyCollectionProvider
      """)
  }
}

extension SectionSource {
  public func flattenedProvider() -> ViewSource {
    return FlattenedProvider(provider: self)
  }
}

extension ViewSource {
  public func flattenedProvider() -> ViewSource {
    return self
  }
}
