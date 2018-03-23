//
//  AnyCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol AnyCollectionProvider: CollectionReloadable {
  var identifier: String? { get }

  // data
  var numberOfItems: Int { get }
  func identifier(at: Int) -> String

  // view
  func view(at: Int) -> UIView
  func update(view: UIView, at: Int)

  // layout
  func layout(collectionSize: CGSize)

  func visibleIndexes(visibleFrame: CGRect) -> [Int]
  var contentSize: CGSize { get }
  func frame(at: Int) -> CGRect

  // event
  func willReload()
  func didReload()
  func didTap(view: UIView, at: Int)

  func presenter(at: Int) -> CollectionPresenter?

  // determines if a context belongs to current provider
  func hasReloadable(_ reloadable: CollectionReloadable) -> Bool
}
