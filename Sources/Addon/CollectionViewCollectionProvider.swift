//
//  CollectionViewProvider.swift
//  CollectionKit
//
//  Created by yansong li on 2018-02-18.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class CollectionViewCollectionProvider: ViewCollectionProvider {

  public var collectionView: CollectionView {
    return views[0] as! CollectionView
  }

  public convenience init(identifier: String? = nil,
                          collectionProvider: AnyCollectionProvider,
                          height: CGFloat,
                          insets: UIEdgeInsets = .zero) {
    self.init(identifier: identifier,
              collectionProvider: collectionProvider,
              sizeStrategy: (.fill, .absolute(height)),
              insets: insets)
  }

  public convenience init(identifier: String? = nil,
                          collectionProvider: AnyCollectionProvider,
                          width: CGFloat,
                          height: CGFloat,
                          insets: UIEdgeInsets = .zero) {
    self.init(identifier: identifier,
              collectionProvider: collectionProvider,
              sizeStrategy: (.absolute(width), .absolute(height)),
              insets: insets)
  }

  public init(identifier: String? = nil,
              collectionProvider: AnyCollectionProvider,
              sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy),
              insets: UIEdgeInsets = .zero) {
    let collectionView = CollectionView()
    collectionView.provider = collectionProvider
    super.init(identifier: identifier,
               views: [collectionView],
               sizeStrategy: sizeStrategy,
               layout: insets == .zero ? FlowLayout() : FlowLayout().inset(by: insets))
  }
}
