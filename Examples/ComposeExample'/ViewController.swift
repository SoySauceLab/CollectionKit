//
//  ViewController.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

let bodyInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
let headerInset = UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16)

func section(title: String, provider: AnyCollectionProvider) -> AnyCollectionProvider {
  let titleSection = LabelCollectionProvider(text: title, font: .boldSystemFont(ofSize: 30), insets: headerInset)
  return CollectionComposer(titleSection, provider)
}

func space(_ height: CGFloat) -> AnyCollectionProvider {
  return SpaceCollectionProvider(.fillWidth(height: height))
}

class ViewController: UIViewController {
  
  @IBOutlet var collectionView: CollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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

    let image1Section = SingleViewCollectionProvider(view: imageCollectionView, sizeStrategy: .fillWidth(height: 400))
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
                                                 space(100),
                                                 CollectionComposer(titleSection, subtitleSection),
                                                 section(title: "Horizontal Waterfall Layout", provider: image1Section),
                                                 space(20),
                                                 section(title: "Vertical Waterfall Layout", provider: image2Section))
  }
}

