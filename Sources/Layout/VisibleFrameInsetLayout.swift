//
//  VisibleFrameInsetLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-03-23.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class VisibleFrameInsetLayout<Data>: WrapperLayout<Data> {
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

  open override func layout(collectionSize: CGSize,
                            dataProvider: CollectionDataProvider<Data>,
                            sizeProvider: @escaping (Int, Data, CGSize) -> CGSize) {
    if let insetProvider = insetProvider {
      insets = insetProvider(collectionSize)
    }
    super.layout(collectionSize: collectionSize,
                 dataProvider: dataProvider,
                 sizeProvider: sizeProvider)
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(visibleFrame: visibleFrame.inset(by: insets))
  }
}
