//
//  LabelCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class LabelCollectionProvider: SingleViewCollectionProvider {
  public init(text: String, font: UIFont = .systemFont(ofSize: 12), color: UIColor = .black, insets: UIEdgeInsets = .zero) {
    let label = UILabel()
    label.font = font
    label.textColor = color
    label.text = text
    super.init(view: label, insets: insets)
  }
}
