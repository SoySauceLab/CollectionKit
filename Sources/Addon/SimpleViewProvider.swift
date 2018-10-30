//
//  SingleViewCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class SimpleViewProvider: BasicProvider<UIView, UIView> {

  open var views: [UIView] {
    get { return viewDataSource.data }
    set { viewDataSource.data = newValue }
  }

  open var identifierMapper: IdentifierMapperFn<UIView> {
    get { return viewDataSource.identifierMapper }
    set { viewDataSource.identifierMapper = newValue }
  }

  private let viewDataSource: ArrayDataSource<UIView>

  private class SimpleViewProviderViewSource: ViewSource<UIView, UIView> {
    override func view(data: UIView, index: Int) -> UIView {
      return data
    }
  }

  public init(identifier: String? = nil,
              views: [UIView] = [],
              identifierMapper: @escaping IdentifierMapperFn<UIView> = { return "\($1.hash)" },
              sizeSource: SizeSource<UIView> = SizeSource<UIView>(),
              layout: Layout = FlowLayout(),
              animator: Animator? = nil,
              tapHandler: TapHandler? = nil) {

    viewDataSource = ArrayDataSource(data: views, identifierMapper: identifierMapper)

    super.init(identifier: identifier,
               dataSource: viewDataSource,
               viewSource: SimpleViewProviderViewSource(),
               sizeSource: sizeSource,
               layout: layout,
               animator: animator,
               tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          views: [UIView] = [],
                          sizeStrategy: (width: SimpleViewSizeSource.ViewSizeStrategy,
                                         height: SimpleViewSizeSource.ViewSizeStrategy) = (.fit, .fit),
                          layout: Layout = FlowLayout(),
                          identifierMapper: @escaping (Int, UIView) -> String = { index, view in
                            return "\(view.hash)"
                          }) {
    self.init(identifier: identifier,
              views: views,
              identifierMapper: identifierMapper,
              sizeSource: SimpleViewSizeSource(sizeStrategy: sizeStrategy),
              layout: layout)
  }
}
