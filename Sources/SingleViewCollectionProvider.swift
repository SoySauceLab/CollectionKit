//
//  SingleViewCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class SingleViewCollectionProvider: CollectionProvider<UIView, UIView> {
  private class SingleViewProvider: CollectionViewProvider<UIView, UIView> {
    var view: UIView
    init(view: UIView) {
      self.view = view
      super.init()
    }
    override func view(at: Int) -> UIView {
      return view
    }
  }
  
  public enum SingleViewSizeStrategy {
    case sizeThatFits
    case fillWidth(height: CGFloat?)
    case fillHeight(width: CGFloat?)
    case absolute(size: CGSize)
  }
  public init(view: UIView, sizeStrategy: SingleViewSizeStrategy = .sizeThatFits, insets: UIEdgeInsets = .zero) {
    super.init(dataProvider: ArrayDataProvider(data: [view]),
               viewProvider: SingleViewProvider(view: view),
               sizeProvider: ClosureSizeProvider(sizeProvider: { (_, view, size) -> CGSize in
                let fitSize = view.sizeThatFits(size)
                switch sizeStrategy {
                case .sizeThatFits:
                  return fitSize
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
