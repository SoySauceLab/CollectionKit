//
//  BaseCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-15.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

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
