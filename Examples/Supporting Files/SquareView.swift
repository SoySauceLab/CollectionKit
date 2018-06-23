//
//  SquareView.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2018-06-09.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

class SquareView: DynamicView {

  let textLabel = UILabel()

  var text: String? {
    get { return textLabel.text }
    set { textLabel.text = newValue }
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    layer.cornerRadius = 4

    textLabel.textColor = .white
    textLabel.textAlignment = .center
    addSubview(textLabel)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    textLabel.frame = bounds
  }

}
