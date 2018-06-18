//
//  BasicProviderBuilder.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-12.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

public class BasicProviderBuilder {
  public static func with<Data>(dataSource: DataSource<Data>) -> PartialBasicProviderBuilder<Data> {
    return PartialBasicProviderBuilder<Data>(dataSource: dataSource)
  }

  public static func with<Data>(data: [Data]) -> PartialBasicProviderBuilder<Data> {
    return with(dataSource: ArrayDataSource(data: data))
  }
}

public class PartialBasicProviderBuilder<Data> {
  let dataSource: DataSource<Data>
  init(dataSource: DataSource<Data>) {
    self.dataSource = dataSource
  }
  public func with<View: UIView>(viewSource: ViewSource<Data, View>) -> FullBasicProviderBuilder<Data, View> {
    return FullBasicProviderBuilder(dataSource: dataSource, viewSource: viewSource)
  }
  public func with<View: UIView>(
    viewGenerator: ((Data, Int) -> View)? = nil,
    viewUpdater: @escaping (View, Data, Int) -> Void) -> FullBasicProviderBuilder<Data, View> {
    return with(viewSource: ClosureViewSource(viewGenerator: viewGenerator, viewUpdater: viewUpdater))
  }
}

public class FullBasicProviderBuilder<Data, View: UIView> {
  let dataSource: DataSource<Data>
  let viewSource: ViewSource<Data, View>

  var identifier: String?
  var sizeSource: SizeSource<Data>?
  var layout: Layout?
  var presenter: Presenter?

  var tapHandler: BasicProvider<Data, View>.TapHandler?

  init(dataSource: DataSource<Data>, viewSource: ViewSource<Data, View>) {
    self.dataSource = dataSource
    self.viewSource = viewSource
  }

  public func with(identifier: String) -> Self {
    self.identifier = identifier
    return self
  }
  public func with(sizeSource: @escaping SizeSource<Data>) -> Self {
    self.sizeSource = sizeSource
    return self
  }
  public func with(layout: Layout) -> Self {
    self.layout = layout
    return self
  }
  public func with(presenter: Presenter) -> Self {
    self.presenter = presenter
    return self
  }
  public func with(tapHandler: @escaping BasicProvider<Data, View>.TapHandler) -> Self {
    self.tapHandler = tapHandler
    return self
  }

  public func build() -> BasicProvider<Data, View> {
    return BasicProvider(identifier: identifier,
                         dataSource: dataSource,
                         viewSource: viewSource,
                         layout: layout ?? FlowLayout(),
                         sizeSource: sizeSource ?? defaultSizeSource,
                         presenter: presenter,
                         tapHandler: tapHandler)
  }
}
