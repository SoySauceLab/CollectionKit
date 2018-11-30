//
//  Layout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class Layout {

  open func layout(context: LayoutContext) {
    fatalError("Subclass should provide its own layout")
  }

  open var contentSize: CGSize {
    fatalError("Subclass should provide its own layout")
  }

  open func frame(at: Int) -> CGRect {
    fatalError("Subclass should provide its own layout")
  }

  open func visible(for visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect) {
    fatalError("Subclass should provide its own layout")
  }

  public init() {}
}

extension Layout {
  public func transposed() -> TransposeLayout {
    return TransposeLayout(self)
  }

  public func inset(by insets: UIEdgeInsets) -> InsetLayout {
    return InsetLayout(self, insets: insets)
  }

  /// Visible insets in the opposite of the layout direction are doubled
  public func insetVisibleFrame(by insets: UIEdgeInsets) -> VisibleFrameInsetLayout {
    return VisibleFrameInsetLayout(self, insets: insets)
  }
}
