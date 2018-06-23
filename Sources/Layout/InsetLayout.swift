//
//  InsetLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class InsetLayout: WrapperLayout {
  public var insets: UIEdgeInsets
  public var insetProvider: ((CGSize) -> UIEdgeInsets)?

  struct InsetLayoutContext: LayoutContext {
    var original: LayoutContext
    var insets: UIEdgeInsets

    var collectionSize: CGSize {
      return original.collectionSize.insets(by: insets)
    }
    var numberOfItems: Int {
      return original.numberOfItems
    }
    func data(at: Int) -> Any {
      return original.data(at: at)
    }
    func identifier(at: Int) -> String {
      return original.identifier(at: at)
    }
    func size(at: Int, collectionSize: CGSize) -> CGSize {
      return original.size(at: at, collectionSize: collectionSize)
    }
  }

  public init(_ rootLayout: Layout, insets: UIEdgeInsets = .zero) {
    self.insets = insets
    super.init(rootLayout)
  }

  public init(_ rootLayout: Layout, insetProvider: @escaping ((CGSize) -> UIEdgeInsets)) {
    self.insets = .zero
    self.insetProvider = insetProvider
    super.init(rootLayout)
  }

  open override var contentSize: CGSize {
    return rootLayout.contentSize.insets(by: -insets)
  }

  open override func layout(context: LayoutContext) {
    if let insetProvider = insetProvider {
      insets = insetProvider(context.collectionSize)
    }
    rootLayout.layout(context: InsetLayoutContext(original: context, insets: insets))
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(visibleFrame: visibleFrame.inset(by: -insets))
  }

  open override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at) + CGPoint(x: insets.left, y: insets.top)
  }
}
