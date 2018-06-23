//
//  VisibleFrameInsetLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-03-23.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class VisibleFrameInsetLayout: WrapperLayout {
  public var insets: UIEdgeInsets
  public var insetProvider: ((CGSize) -> UIEdgeInsets)?

  public init(_ rootLayout: Layout, insets: UIEdgeInsets = .zero) {
    self.insets = insets
    super.init(rootLayout)
  }

  public init(_ rootLayout: Layout, insetProvider: @escaping ((CGSize) -> UIEdgeInsets)) {
    self.insets = .zero
    self.insetProvider = insetProvider
    super.init(rootLayout)
  }

  open override func layout(context: LayoutContext) {
    if let insetProvider = insetProvider {
      insets = insetProvider(context.collectionSize)
    }
    super.layout(context: context)
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(visibleFrame: visibleFrame.inset(by: insets))
  }
}
