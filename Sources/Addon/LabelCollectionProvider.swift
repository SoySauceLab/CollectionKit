//
//  LabelCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class LabelCollectionProvider: ViewCollectionProvider {
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
