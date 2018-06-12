//
//  AnyProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol BaseProviderType {
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

  func presenter(at: Int) -> Presenter?

  // determines if a context belongs to current provider
  func hasReloadable(_ reloadable: CollectionReloadable) -> Bool

  func flattenedProvider() -> ItemProviderType
}

public protocol SectionProviderType: BaseProviderType {
  func section(at: Int) -> AnyProvider?
}

public protocol ItemProviderType: BaseProviderType {
  func view(at: Int) -> UIView
  func update(view: UIView, at: Int)

  func didTap(view: UIView, at: Int)
}

public typealias AnyProvider = BaseProviderType & CollectionReloadable

extension BaseProviderType {
  public func flattenedProvider() -> ItemProviderType {
    fatalError("""
      AnyCollectionProvider shouldn't be used by itself,
      please use either SectionProviderType or ItemProviderType
      """)
  }
}

extension SectionProviderType {
  public func flattenedProvider() -> ItemProviderType {
    return FlattenedProvider(provider: self)
  }
}

extension ItemProviderType {
  public func flattenedProvider() -> ItemProviderType {
    return self
  }
}
