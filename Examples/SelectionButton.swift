//
//  SelectionButton.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-25.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

class SelectionButton: DynamicView {
  let label = UILabel()
  override init(frame: CGRect) {
    super.init(frame: frame)
    label.textAlignment = .center
    layer.cornerRadius = 5
    addSubview(label)
  }
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    label.frame = bounds
  }
}
