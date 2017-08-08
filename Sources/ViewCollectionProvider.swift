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
    case sizeThatFits
    case fill
    case fillWidth(height: CGFloat?)
    case fillHeight(width: CGFloat?)
    case absolute(size: CGSize)
  }

  public init(_ views: UIView..., sizeStrategy: ViewSizeStrategy = .sizeThatFits, insets: UIEdgeInsets = .zero) {
    super.init(dataProvider: ArrayDataProvider(data: views, identifierMapper: {
                return "\($0.1.hash)"
               }),
               viewProvider: ViewProvider(views: views),
               sizeProvider: ClosureSizeProvider(sizeProvider: { (_, view, size) -> CGSize in
                let fitSize = view.sizeThatFits(size)
                switch sizeStrategy {
                case .sizeThatFits:
                  return fitSize
                case .fill:
                  return size
                case .fillWidth(let height):
                  return CGSize(width: size.width, height: height ?? fitSize.height)
                case .fillHeight(let width):
                  return CGSize(width: width ?? fitSize.width, height: size.height)
                case .absolute(let size):
                  return size
                }
               }))
    layout.insets = insets
  }
}
