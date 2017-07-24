//
//  ComposeViewController.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class ComposeViewController: UIViewController {
  
  let collectionView = CollectionView()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    
    let bodyInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    let headerInset = UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16)
    let imageCollectionView = CollectionView()
    imageCollectionView.provider = CollectionProvider(
      dataProvider: ArrayDataProvider(data: testImages),
      viewProvider: ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
      }),
      layoutProvider: WaterfallLayout<UIImage>(insets: bodyInset, axis: .horizontal),
      sizeProvider: ImageSizeProvider(),
      presenter: WobblePresenter()
    )
    
    let titleSection = LabelCollectionProvider(text: "CollectionKit", font: .boldSystemFont(ofSize: 40), insets: headerInset)
    let subtitleSection = LabelCollectionProvider(text: "A modern swift framework for building reusable collection view components.", font: .systemFont(ofSize: 22), insets: bodyInset)
    
    let label1Section = LabelCollectionProvider(text: "Section 1", font: .boldSystemFont(ofSize: 30), insets: headerInset)
    let image1Section = SingleViewCollectionProvider(view: imageCollectionView, sizeStrategy: .fillWidth(height: 400))
    let label2Section = LabelCollectionProvider(text: "Section 2", font: .boldSystemFont(ofSize: 30), insets: headerInset)
    let image2Section = CollectionProvider(
      dataProvider: ArrayDataProvider(data: testImages),
      viewProvider: ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
      }),
      layoutProvider: WaterfallLayout<UIImage>(insets: bodyInset, axis: .vertical),
      sizeProvider: ImageSizeProvider(),
      presenter: WobblePresenter()
    )
    
    collectionView.provider = CollectionComposer(layoutProvider: FlowLayout(),
      SpaceCollectionProvider(.fillWidth(height: 80)),
      CollectionComposer(titleSection, subtitleSection),
      CollectionComposer(label1Section, image1Section),
      SpaceCollectionProvider(.fillWidth(height: 20)),
      CollectionComposer(label2Section, image2Section))
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
  }

}

