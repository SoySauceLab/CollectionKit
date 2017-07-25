//
//  CardView.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-25.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

class CardView: UIView {
  let titleLabel = UILabel()
  let subtitleLabel = UILabel()
  var title: String = "" {
    didSet {
      titleLabel.text = title
      setNeedsLayout()
    }
  }
  var subtitle: String = "" {
    didSet {
      subtitleLabel.text = subtitle
      setNeedsLayout()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    layer.cornerRadius = 8
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 12)
    layer.shadowRadius = 10
    layer.shadowOpacity = 0.1
    layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
    layer.borderWidth = 0.5

    titleLabel.font = .boldSystemFont(ofSize: 26)
    addSubview(titleLabel)
    subtitleLabel.font = .systemFont(ofSize: 18)
    subtitleLabel.numberOfLines = 0
    addSubview(subtitleLabel)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let size = titleLabel.sizeThatFits(bounds.insetBy(dx: 16, dy: 10).size)
    titleLabel.frame = CGRect(origin: CGPoint(x: 16, y: 10), size: size)
    let subtitleSize = subtitleLabel.sizeThatFits(CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - titleLabel.frame.maxY).insetBy(dx: 16, dy: 10).size)
    subtitleLabel.frame = CGRect(origin: CGPoint(x: 16, y: titleLabel.frame.maxY + 10), size: subtitleSize)
  }
}
