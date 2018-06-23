//
//  SingleViewCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class SimpleViewProvider: ItemProvider, CollectionReloadable {

  public enum ViewSizeStrategy {
    case fill
    case fit
    case absolute(CGFloat)
  }

  public var identifier: String?
  public var layout: Layout
  public var views: [UIView] { didSet { setNeedsReload() } }
  public var sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy) {
    didSet { setNeedsReload() }
  }
  public var sizeStrategyOverride: [UIView: (width: ViewSizeStrategy, height: ViewSizeStrategy)] = [:] {
    didSet { setNeedsReload() }
  }
  public var animator: Animator? { didSet { setNeedsReload() } }

  public init(identifier: String? = nil,
              views: [UIView] = [],
              sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy) = (.fit, .fit),
              layout: Layout = FlowLayout()) {
    self.identifier = identifier
    self.layout = layout
    self.sizeStrategy = sizeStrategy
    self.views = views
  }

  public var numberOfItems: Int {
    return views.count
  }

  public func identifier(at: Int) -> String {
    return "\(views[at].hash)"
  }

  public func layout(collectionSize: CGSize) {
    let context = SimpleViewLayoutContext(
      collectionSize: collectionSize,
      views: views,
      sizeStrategy: sizeStrategy,
      sizeStrategyOverride: sizeStrategyOverride
      )
    layout.layout(context: context)
  }

  public func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return layout.visibleIndexes(visibleFrame: visibleFrame)
  }

  public var contentSize: CGSize {
    return layout.contentSize
  }

  public func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }

  public func view(at: Int) -> UIView {
    return views[at]
  }

  public func animator(at: Int) -> Animator? {
    return animator
  }

  public func update(view: UIView, at: Int) {}
  public func didTap(view: UIView, at: Int) {}

  struct SimpleViewLayoutContext: LayoutContext {
    let collectionSize: CGSize
    let views: [UIView]
    let sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy)
    let sizeStrategyOverride: [UIView: (width: ViewSizeStrategy, height: ViewSizeStrategy)]
    var numberOfItems: Int {
      return views.count
    }
    func data(at: Int) -> Any {
      return views[at]
    }
    func identifier(at: Int) -> String {
      return "\(views[at].hash)"
    }
    func size(at: Int, collectionSize: CGSize) -> CGSize {
      let view = views[at]
      let fitSize = view.sizeThatFits(collectionSize)
      let sizeStrategy = sizeStrategyOverride[view] ?? self.sizeStrategy
      let width: CGFloat, height: CGFloat

      switch sizeStrategy.width {
      case .fit: width = fitSize.width
      case .fill: width = collectionSize.width
      case .absolute(let value): width = value
      }
      switch sizeStrategy.height {
      case .fit: height = fitSize.height
      case .fill: height = collectionSize.height
      case .absolute(let value): height = value
      }

      return CGSize(width: width, height: height)
    }
  }
}
