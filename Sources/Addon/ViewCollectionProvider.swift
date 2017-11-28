//
//  SingleViewCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class ViewCollectionProvider: CollectionProvider<UIView, UIView> {
  private class ViewProvider: CollectionViewProvider<UIView, UIView> {
    override func view(data: UIView, index: Int) -> UIView {
      return data
    }
  }

  public enum ViewSizeStrategy {
    case fill
    case fit
    case absolute(CGFloat)
  }

  public convenience init(identifier: String? = nil,
                          _ views: UIView...,
                          sizeStrategy: (ViewSizeStrategy, ViewSizeStrategy) = (.fit, .fit),
                          insets: UIEdgeInsets = .zero) {
    self.init(identifier: identifier, views: views, sizeStrategy: sizeStrategy,
              layout: insets == .zero ? FlowLayout() : FlowLayout().inset(by: insets))
  }

  public init(identifier: String? = nil,
              views: [UIView],
              sizeStrategy: (ViewSizeStrategy, ViewSizeStrategy) = (.fit, .fit),
              layout: CollectionLayout<UIView>) {
    super.init(dataProvider: ArrayDataProvider(data: views, identifierMapper: {
                 return "\($1.hash)"
               }),
               viewProvider: ViewProvider())
    self.identifier = identifier
    self.layout = layout
    sizeProvider = { (_, view, size) -> CGSize in
      let fitSize = view.sizeThatFits(size)
      let width: CGFloat, height: CGFloat
      switch sizeStrategy.0 {
      case .fit: width = fitSize.width
      case .fill: width = size.width
      case .absolute(let value): width = value
      }
      switch sizeStrategy.1 {
      case .fit: height = fitSize.height
      case .fill: height = size.height
      case .absolute(let value): height = value
      }

      return CGSize(width: width, height: height)
    }
  }
}
