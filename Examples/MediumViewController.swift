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
      data: testArticles,
      viewUpdater: { (view: ArticleView, data: ArticleData, at: Int) in
        view.populateWithArticle(data)
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
}
