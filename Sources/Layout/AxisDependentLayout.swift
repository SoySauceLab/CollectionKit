//
//  AxisDependentLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public enum Axis{
  case vertical, horizontal
}

public class AxisDependentLayout<Data>: CollectionLayout<Data> {
  public var axis: Axis = .vertical

  public override func doneLayout() {
    visibleIndexSorter = axis == .vertical ? CollectionVerticalVisibleIndexSorter(frames: frames) : CollectionHorizontalVisibleIndexSorter(frames: frames)
  }
  
  func primary(_ size: CGSize) -> CGFloat {
    return axis == .vertical ? size.height : size.width
  }
  func secondary(_ size: CGSize) -> CGFloat {
    return axis != .vertical ? size.height : size.width
  }
  func primary(_ point: CGPoint) -> CGFloat {
    return axis == .vertical ? point.y : point.x
  }
  func secondary(_ point: CGPoint) -> CGFloat {
    return axis != .vertical ? point.y : point.x
  }
  func size(primary: CGFloat, secondary: CGFloat) -> CGSize {
    return axis == .vertical ? CGSize(width: secondary, height: primary) : CGSize(width: primary, height: secondary)
  }
  func point(primary: CGFloat, secondary: CGFloat) -> CGPoint {
    return axis == .vertical ? CGPoint(x: secondary, y: primary) : CGPoint(x: primary, y: secondary)
  }
}
