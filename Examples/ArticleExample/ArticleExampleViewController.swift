//
//  MediumViewController.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-03.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import CollectionKit
import UIKit

class ArticleExampleViewController: CollectionViewController {

  let articles: [ArticleData] = {
    let count = 20
    return (1...count).map {
      ArticleData(hueValue: CGFloat($0) / CGFloat(count),
                  title: "Article \($0)",
                  subTitle: "This is the subtitle for article \($0)")
    }
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    provider = CollectionProvider(
      data: articles,
      viewUpdater: { (view: ArticleView, data: ArticleData, at: Int) in
        view.populate(article: data)
      },
      layout: FlowLayout(insets: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16), lineSpacing: 30),
      sizeProvider: { (_, view, size) -> CGSize in
        return CGSize(width: size.width, height: 200)
      }
    )
  }

}
