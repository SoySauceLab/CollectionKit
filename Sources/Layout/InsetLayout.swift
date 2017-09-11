//
//  InsetLayout.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-09-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class InsetLayout<Data>: WrapperLayout<Data> {
  var insets: UIEdgeInsets

  public init(_ rootLayout: CollectionLayout<Data>, insets: UIEdgeInsets = .zero) {
    self.insets = insets
    super.init(rootLayout)
  }

  open override var contentSize: CGSize {
    return rootLayout.contentSize.insets(by: -insets)
  }

  override public func layout(collectionSize: CGSize,
                                dataProvider: CollectionDataProvider<Data>,
                                sizeProvider: @escaping (Int, Data, CGSize) -> CGSize) {
    rootLayout.layout(collectionSize: collectionSize.insets(by: insets),
                      dataProvider: dataProvider, sizeProvider: sizeProvider)
  }

  public override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    return rootLayout.visibleIndexes(activeFrame: activeFrame.insets(by: -insets))
  }

  public override func frame(at: Int) -> CGRect {
    return rootLayout.frame(at: at) + CGPoint(x: insets.left, y: insets.top)
  }
}
