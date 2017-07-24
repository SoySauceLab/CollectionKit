//
//  HorizontalGalleryViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2016-06-14.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class ImageSizeProvider: CollectionSizeProvider<UIImage> {
  override func size(at: Int, data: UIImage, collectionSize: CGSize) -> CGSize {
    var imageSize = data.size
    if imageSize.width > collectionSize.width {
      imageSize.height /= imageSize.width/collectionSize.width
      imageSize.width = collectionSize.width
    }
    if imageSize.height > collectionSize.height {
      imageSize.width /= imageSize.height/collectionSize.height
      imageSize.height = collectionSize.height
    }
    return imageSize
  }
}

let testImages: [UIImage] = [
  UIImage(named: "l1")!,
  UIImage(named: "l2")!,
  UIImage(named: "l3")!,
  UIImage(named: "1")!,
  UIImage(named: "2")!,
  UIImage(named: "3")!,
  UIImage(named: "4")!,
  UIImage(named: "5")!,
  UIImage(named: "6")!
]

class HorizontalGalleryViewController: UIViewController {

  var collectionView = CollectionView()
  let images = testImages + testImages

  override func viewDidLoad() {
    super.viewDidLoad()

    let dataProvider = ArrayDataProvider(data: images)
    let viewProvider = ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
      view.image = data
      view.layer.cornerRadius = 5
      view.clipsToBounds = true
      view.yaal.rotation.setTo(CGFloat.random(-0.035, max: 0.035))
    })
    let layoutProvider = HorizontalWaterfallLayoutProvider<UIImage>()
    let sizeProvider = ImageSizeProvider()

    let provider1 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layoutProvider: layoutProvider,
      sizeProvider: sizeProvider
    )
    let provider2 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layoutProvider: layoutProvider,
      sizeProvider: sizeProvider,
      presenter: WobblePresenter()
    )
    let provider3 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layoutProvider: layoutProvider,
      sizeProvider: sizeProvider,
      presenter: ZoomPresenter()
    )

    collectionView.provider = CollectionComposer(layoutProvider: HorizontalWaterfallLayoutProvider(), provider1, provider2, provider3)
    view.addSubview(collectionView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length + 10, 10, 10, 10)
  }
}
