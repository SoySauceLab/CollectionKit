//
//  InsetLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class InsetLayout<Data>: WrapperLayout<Data> {
  public var insets: UIEdgeInsets
  public var insetProvider: ((CGSize) -> UIEdgeInsets)?

  public init(_ rootLayout: CollectionLayout<Data>, insets: UIEdgeInsets = .zero) {
    self.insets = insets
    super.init(rootLayout)
  }

  public init(_ rootLayout: CollectionLayout<Data>, insetProvider: @escaping ((CGSize) -> UIEdgeInsets)) {
    self.insets = .zero
    self.insetProvider = insetProvider
    super.init(rootLayout)
  }

  open override var contentSize: CGSize {
    return rootLayout.contentSize.insets(by: -insets)
  }

  open override func layout(collectionSize: CGSize,
                            dataProvider: CollectionDataProvider<Data>,
                            sizeProvider: @escaping (Int, Data, CGSize) -> CGSize) {
    if let insetProvider = insetProvider {
      insets = insetProvider(collectionSize)
    }
    rootLayout.layout(collectionSize: collectionSize.insets(by: insets),
                      dataProvider: dataProvider, sizeProvider: sizeProvider)
  }

  open override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(activeFrame: activeFrame.inset(by: -insets))
  }

  open override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at) + CGPoint(x: insets.left, y: insets.top)
  }
}
