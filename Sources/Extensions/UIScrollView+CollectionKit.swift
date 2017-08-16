//
//  UIScrollView+Addtion.swift
//  CollectionView
//
//  Created by Luke on 4/16/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

extension UIScrollView {
  public var visibleFrame: CGRect {
    return bounds
  }
  public var visibleFrameLessInset: CGRect {
    return UIEdgeInsetsInsetRect(visibleFrame, contentInset)
  }
  public var absoluteFrameLessInset: CGRect {
    return UIEdgeInsetsInsetRect(CGRect(origin:.zero, size:bounds.size), contentInset)
  }
  public var innerSize: CGSize {
    return absoluteFrameLessInset.size
  }
  public var offsetFrame: CGRect {
    return CGRect(x: -contentInset.left, y: -contentInset.top,
                  width: max(0, contentSize.width - bounds.width + contentInset.right + contentInset.left),
                  height: max(0, contentSize.height - bounds.height + contentInset.bottom + contentInset.top))
  }
  public func absoluteLocation(for point: CGPoint) -> CGPoint {
    return point - contentOffset
  }
  public func scrollTo(edge: UIRectEdge, animated: Bool) {
    let target: CGRect
    switch edge {
    case UIRectEdge.top:
      target = CGRect(x: contentOffset.x, y: offsetFrame.minY, width: 1, height: 1)
    case UIRectEdge.bottom:
      target = CGRect(x: contentOffset.x, y: offsetFrame.maxY - 1, width: 1, height: 1)
    case UIRectEdge.left:
      target = CGRect(x: offsetFrame.minX, y: contentOffset.y, width: 1, height: 1)
    case UIRectEdge.right:
      target = CGRect(x: offsetFrame.maxX - 1, y: contentOffset.y, width: 1, height: 1)
    default:
      return
    }
    scrollRectToVisible(target, animated: animated)
  }
}
