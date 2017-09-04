//
//  ArticleView.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-03.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

class ArticleView: UIView {
  let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 3.0
    return imageView
  }()

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
    self.addSubview(imageView)
    self.addSubview(titleLabel)
    self.addSubview(subTitleLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func populateWithArticle(_ data: ArticleData) {
    imageView.image = UIImage(named: data.imageName)
    titleLabel.text = data.title
    subTitleLabel.text = data.subTitle
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    imageView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 120)
    titleLabel.frame = CGRect(x: 0, y: 130, width: bounds.width, height: 30)
    subTitleLabel.frame = CGRect(x: 0, y: 160, width: bounds.width, height: 40)
  }
}
