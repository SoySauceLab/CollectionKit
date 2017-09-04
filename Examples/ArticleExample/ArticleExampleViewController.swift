//
//  MediumViewController.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-03.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import CollectionKit
import UIKit

class ArticleExampleViewController: UIViewController {
  
  var collectionView: CollectionView = {
    let collectionView = CollectionView()
    collectionView.backgroundColor = .white
    return collectionView
  }()

  let articles: [ArticleData] = {
    let count = 20
    return (1...count).map {
      ArticleData(hueValue: CGFloat($0) / CGFloat(count),
                  title: "Article \($0)",
                  subTitle: "This is the subtitle for article \($0)")
    }
  }()

  override func loadView() {
    self.view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    let provider = CollectionProvider(
      data: articles,
      viewUpdater: { (view: ArticleView, data: ArticleData, at: Int) in
        view.populate(article: data)
      },
      layout: FlowLayout(insets: UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16), padding: 30),
      sizeProvider: { (_, view, size) -> CGSize in
        return CGSize(width: size.width, height: 200)
      })
    collectionView.provider = provider
  }

  override var prefersStatusBarHidden: Bool {
    return true
  }
}
