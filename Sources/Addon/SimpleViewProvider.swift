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

  open var identifierMapper: (Int, UIView) -> String {
    didSet {
      setNeedsReload()
    }
  }

  open var identifier: String?
  open var layout: Layout
  open var views: [UIView] { didSet { setNeedsReload() } }
  open var sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy) {
    didSet { setNeedsReload() }
  }
  open var sizeStrategyOverride: [UIView: (width: ViewSizeStrategy, height: ViewSizeStrategy)] = [:] {
    didSet { setNeedsReload() }
  }
  open var animator: Animator? { didSet { setNeedsReload() } }
  open var tapHandler: ((UIView) -> Void)?

  public init(identifier: String? = nil,
              views: [UIView] = [],
              sizeStrategy: (width: ViewSizeStrategy, height: ViewSizeStrategy) = (.fit, .fit),
              layout: Layout = FlowLayout(),
              identifierMapper: @escaping (Int, UIView) -> String = { index, view in
                return "\(view.hash)"
              }) {
    self.identifier = identifier
    self.layout = layout
    self.sizeStrategy = sizeStrategy
    self.views = views
    self.identifierMapper = identifierMapper
  }

  open var numberOfItems: Int {
    return views.count
  }

  open func identifier(at: Int) -> String {
    return identifierMapper(at, views[at])
  }

  open func layout(collectionSize: CGSize) {
    let context = SimpleViewLayoutContext(
      collectionSize: collectionSize,
      views: views,
      sizeStrategy: sizeStrategy,
      sizeStrategyOverride: sizeStrategyOverride
      )
    layout.layout(context: context)
  }

  open func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return layout.visibleIndexes(visibleFrame: visibleFrame)
  }

  open var contentSize: CGSize {
    return layout.contentSize
  }

  open func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }

  open func view(at: Int) -> UIView {
    return views[at]
  }

  open func animator(at: Int) -> Animator? {
    return animator
  }

  open func update(view: UIView, at: Int) {}
  open func didTap(view: UIView, at: Int) {
    tapHandler?(view)
  }

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
