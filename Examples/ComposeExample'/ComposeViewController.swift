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
    
    let defaultInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let imageCollectionView = CollectionView()
    imageCollectionView.provider = CollectionProvider(
      dataProvider: ArrayDataProvider(data: testImages),
      viewProvider: ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.yaal.rotation.setTo(CGFloat.random(-0.035, max: 0.035))
      }),
      layoutProvider: HorizontalWaterfallLayoutProvider<UIImage>(insets: defaultInsets),
      sizeProvider: ImageSizeProvider(),
      presenter: WobblePresenter()
    )
    
    let labelSection = LabelCollectionProvider(text: "Section 1", font: .boldSystemFont(ofSize: 30), insets: defaultInsets)
    let imageSection = SingleViewCollectionProvider(view: imageCollectionView, sizeStrategy: .fillWidth(height: 200))
    let label2Section = LabelCollectionProvider(text: "Section 2", font: .boldSystemFont(ofSize: 30), insets: defaultInsets)
    
    collectionView.provider = CollectionComposer(layoutProvider: FlowLayout(),
      labelSection,
      imageSection,
      SpaceCollectionProvider(.fillWidth(height: 50)),
      label2Section)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
  }

}

