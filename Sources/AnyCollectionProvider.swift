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
  
  func visibleIndexes(activeFrame: CGRect) -> Set<Int>
  var contentSize: CGSize { get }
  func frame(at: Int) -> CGRect
  
  // event
  func willReload()
  func didReload()
  func willDrag(view: UIView, at:Int) -> Bool
  func didDrag(view: UIView, at:Int)
  func moveItem(at: Int, to: Int) -> Bool
  func didTap(view: UIView, at: Int)

  func presenter(at: Int) -> CollectionPresenter?
  
  // determines if a context belongs to current provider
  func hasReloadable(_ reloadable: CollectionReloadable) -> Bool
}

open class BaseCollectionProvider: AnyCollectionProvider {
  public var identifier: String?

  public init() {}

  open var numberOfItems: Int {
    return 0
  }
  open func view(at: Int) -> UIView {
    return UIView()
  }
  open func update(view: UIView, at: Int) {}
  open func identifier(at: Int) -> String {
    return "\(at)"
  }

  open var contentSize: CGSize {
    return .zero
  }
  open func layout(collectionSize: CGSize) {}
  open func frame(at: Int) -> CGRect {
    return .zero
  }
  open func visibleIndexes(activeFrame: CGRect) -> Set<Int> {
    return Set<Int>()
  }

  open func presenter(at: Int) -> CollectionPresenter? {
    return nil
  }

  open func willReload() {}
  open func didReload() {}
  open func willDrag(view: UIView, at:Int) -> Bool {
    return false
  }
  open func didDrag(view: UIView, at:Int) {}
  open func moveItem(at: Int, to: Int) -> Bool {
    return false
  }
  open func didTap(view: UIView, at: Int) {}

  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self
  }
}
