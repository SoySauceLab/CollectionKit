//
//  Bridge.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-12.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

// MARK: protocols
@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias AnyCollectionProvider = Provider

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias CollectionDataProvider = DataSource

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias CollectionViewProvider = ViewSource

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias CollectionSizeProvider = SizeSource

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias CollectionLayout = Layout

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias CollectionPresenter = Animator

// MARK: providers
@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias CollectionProvider = BasicProvider

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias CollectionComposer = ComposedProvider

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias ViewCollectionProvider = SimpleViewProvider

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias EmptyStateCollectionProvider = EmptyStateProvider

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias SpaceCollectionProvider = SpaceProvider

// MARK: others
@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias ClosureDataProvider = ClosureDataSource

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias ClosureViewProvider = ClosureViewSource

@available(*, deprecated, message: "v2.0 deprecated naming")
public typealias ArrayDataProvider = ArrayDataSource

extension CollectionView {
  @available(*, deprecated, message: "v2.0 deprecated naming")
  public var loading: Bool { return isLoadingCell }

  @available(*, deprecated, message: "v2.0 deprecated naming")
  public var reloading: Bool { return isReloading }
}

extension BasicProvider {
  public typealias OldTapHandler = (View, Int, DataSource<Data>) -> Void

  private static func convertTapHandler(_ tapHandler: OldTapHandler?) -> TapHandler? {
    if let tapHandler = tapHandler {
      return { context in
        tapHandler(context.view, context.index, context.dataSource)
      }
    }
    return nil
  }

  @available(*, deprecated, message: "please use designated init instead")
  public convenience init(identifier: String? = nil,
                          dataProvider: DataSource<Data>,
                          viewProvider: ViewSource<Data, View>,
                          layout: Layout = FlowLayout(),
                          sizeProvider: @escaping SizeSource<Data> = defaultSizeSource,
                          presenter: Animator? = nil,
                          willReloadHandler: (() -> Void)? = nil,
                          didReloadHandler: (() -> Void)? = nil,
                          tapHandler: OldTapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: dataProvider,
              viewSource: viewProvider,
              sizeSource: sizeProvider,
              layout: layout,
              animator: presenter,
              tapHandler: BasicProvider.convertTapHandler(tapHandler))
  }

  @available(*, deprecated, message: "please use designated init instead")
  public convenience init(identifier: String? = nil,
                          dataProvider: DataSource<Data>,
                          viewGenerator: ((Data, Int) -> View)? = nil,
                          viewUpdater: @escaping (View, Data, Int) -> Void,
                          layout: Layout = FlowLayout(),
                          sizeProvider: @escaping SizeSource<Data> = defaultSizeSource,
                          presenter: Animator? = nil,
                          willReloadHandler: (() -> Void)? = nil,
                          didReloadHandler: (() -> Void)? = nil,
                          tapHandler: OldTapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: dataProvider,
              viewSource: ClosureViewProvider(viewGenerator: viewGenerator, viewUpdater: viewUpdater),
              sizeSource: sizeProvider,
              layout: layout,
              animator: presenter,
              tapHandler: BasicProvider.convertTapHandler(tapHandler))
  }

  @available(*, deprecated, message: "please use designated init instead")
  public convenience init(identifier: String? = nil,
                          data: [Data],
                          viewGenerator: ((Data, Int) -> View)? = nil,
                          viewUpdater: @escaping (View, Data, Int) -> Void,
                          layout: Layout = FlowLayout(),
                          sizeProvider: @escaping SizeSource<Data> = defaultSizeSource,
                          presenter: Animator? = nil,
                          willReloadHandler: (() -> Void)? = nil,
                          didReloadHandler: (() -> Void)? = nil,
                          tapHandler: OldTapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: ArrayDataProvider(data: data),
              viewSource: ClosureViewProvider(viewGenerator: viewGenerator, viewUpdater: viewUpdater),
              sizeSource: sizeProvider,
              layout: layout,
              animator: presenter,
              tapHandler: BasicProvider.convertTapHandler(tapHandler))
  }
}

@available(*, deprecated, message: "will be removed soon")
open class LabelCollectionProvider: SimpleViewProvider {
  public var label: UILabel {
    return view(at: 0) as! UILabel
  }
  public init(identifier: String? = nil, insets: UIEdgeInsets = .zero) {
    let label = UILabel()
    label.numberOfLines = 0
    super.init(identifier: identifier, views: [label], sizeStrategy: (.fill, .fit),
               layout: insets == .zero ? FlowLayout() : FlowLayout().inset(by: insets))
  }
  public init(identifier: String? = nil,
              text: String,
              font: UIFont,
              color: UIColor = .black,
              insets: UIEdgeInsets = .zero) {
    let label = UILabel()
    label.font = font
    label.textColor = color
    label.text = text
    label.numberOfLines = 0
    super.init(identifier: identifier, views: [label], sizeStrategy: (.fill, .fit),
               layout: insets == .zero ? FlowLayout() : FlowLayout().inset(by: insets))
  }
  public init(identifier: String? = nil, attributedString: NSAttributedString, insets: UIEdgeInsets = .zero) {
    let label = UILabel()
    label.attributedText = attributedString
    label.numberOfLines = 0
    super.init(identifier: identifier, views: [label], sizeStrategy: (.fill, .fit),
               layout: insets == .zero ? FlowLayout() : FlowLayout().inset(by: insets))
  }
}
