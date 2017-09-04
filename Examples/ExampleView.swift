//
//  ExampleView.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class ExampleView: UIView {
  let titleLabel = UILabel()
  let card = UIView()

  private var contentVC: UIViewController?

  override init(frame: CGRect) {
    super.init(frame: frame)
    card.backgroundColor = .white
    card.layer.cornerRadius = 8
    card.layer.shadowColor = UIColor.black.cgColor
    card.layer.shadowOffset = CGSize(width: 0, height: 12)
    card.layer.shadowRadius = 10
    card.layer.shadowOpacity = 0.1
    card.layer.borderColor = UIColor(white: 0, alpha: 0.1).cgColor
    card.layer.borderWidth = 0.5

    titleLabel.font = .boldSystemFont(ofSize: 22)

    addSubview(titleLabel)
    addSubview(card)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let size = titleLabel.sizeThatFits(bounds.insetBy(dx: 16, dy: 10).size)
    titleLabel.frame = CGRect(origin: CGPoint(x: 0, y: 10), size: size)
    let labelHeight = titleLabel.frame.maxY + 10
    card.frame = CGRect(x: 0, y: labelHeight, width: bounds.width, height: bounds.height - labelHeight)
    contentVC?.view.frame = card.bounds
  }

  func populate(title: String,
                contentViewControllerType: UIViewController.Type) {
    titleLabel.text = title
    contentVC?.view.removeFromSuperview()
    contentVC = contentViewControllerType.init()
    let contentView = contentVC!.view!
    contentView.clipsToBounds = true
    contentView.layer.cornerRadius = 8
    card.addSubview(contentView)
    setNeedsLayout()
  }
}
