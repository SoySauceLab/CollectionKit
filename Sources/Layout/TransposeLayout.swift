//
//  TransposeLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class TransposeLayout: WrapperLayout {
  struct TransposeLayoutContext: LayoutContext {
    var original: LayoutContext

    var collectionSize: CGSize {
      return original.collectionSize.transposed
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
      return original.size(at: at, collectionSize: collectionSize.transposed).transposed
    }
  }

  open override var contentSize: CGSize {
    return rootLayout.contentSize.transposed
  }

  open override func layout(context: LayoutContext) {
    rootLayout.layout(context: TransposeLayoutContext(original: context))
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(visibleFrame: visibleFrame.transposed)
  }

  open override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at).transposed
  }
}
