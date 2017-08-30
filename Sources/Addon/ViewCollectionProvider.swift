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
    var views: [UIView]
    init(views: [UIView]) {
      self.views = views
      super.init()
    }
    override func view(at: Int) -> UIView {
      return views[at]
    }
  }
  
  public enum ViewSizeStrategy {
    case fill
    case fit
    case absolute(CGFloat)
  }

  public init(identifier: String? = nil,
              _ views: UIView...,
              sizeStrategy: (ViewSizeStrategy, ViewSizeStrategy) = (.fit, .fit),
              insets: UIEdgeInsets = .zero) {
    super.init(identifier: identifier,
               dataProvider: ArrayDataProvider(data: views, identifierMapper: {
                return "\($0.1.hash)"
               }),
               viewProvider: ViewProvider(views: views),
               sizeProvider: { (_, view, size) -> CGSize in
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
               })
    layout.insets = insets
  }
}
