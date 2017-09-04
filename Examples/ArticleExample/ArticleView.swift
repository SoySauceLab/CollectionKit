//
//  ArticleView.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-03.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

class ArticleView: UIView {
  let colorView = UIView()

  let titleLabel: UILabel = {
    let titleLabel = UILabel()
    titleLabel.numberOfLines = 1
    titleLabel.font = .boldSystemFont(ofSize: 20)
    return titleLabel
  }()

  let subTitleLabel: UILabel = {
    let subTitleLabel = UILabel()
    subTitleLabel.numberOfLines = 2
    subTitleLabel.font = .systemFont(ofSize: 16)
    return subTitleLabel
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .white
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 12)
    layer.shadowRadius = 10
    layer.shadowOpacity = 0.1
    addSubview(colorView)
    addSubview(titleLabel)
    addSubview(subTitleLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func populate(article data: ArticleData) {
    colorView.backgroundColor =
        UIColor(hue: data.hueValue, saturation: 0.68, brightness: 0.98, alpha: 1)
    titleLabel.text = data.title
    subTitleLabel.text = data.subTitle
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    colorView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 120)
    titleLabel.frame = CGRect(x: 10, y: 130, width: bounds.width - 20, height: 30)
    subTitleLabel.frame = CGRect(x: 10, y: 160, width: bounds.width - 20, height: 30)
  }
}
