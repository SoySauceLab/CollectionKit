//
//  MediumViewController.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-03.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import CollectionKit
import UIKit

class MediumViewController: UIViewController {
  
  var collectionView: CollectionView = {
    let collectionView = CollectionView()
    collectionView.backgroundColor = .white
    return collectionView
  }()

  override func loadView() {
    self.view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let provider = CollectionProvider(
      data: articles(count: 8),
      viewUpdater: { (view: ArticleView, data: ArticleData, at: Int) in
        view.populate(article: data)
      },
      layout: FlowLayout(insets: UIEdgeInsets(top: 20, left: 16, bottom: 16, right: 20), padding: 30),
      sizeProvider: { (_, view, size) -> CGSize in
        return CGSize(width: size.width, height: 200)
      })
    collectionView.provider = provider
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }

  private func articles(count: Int) -> [ArticleData] {
    var articles: [ArticleData] = []
    for i in 0..<count {
      articles.append(
        ArticleData(hueValue: CGFloat(i) / CGFloat(count),
                    title: "Article \(i)",
                    subTitle: "This is the subtitle for article \(i)")
      )
    }
    return articles
  }
}
