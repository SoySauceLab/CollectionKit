//
//  HorizontalGalleryViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2016-06-14.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

func sizeForImage(_ imageSize: CGSize, maxSize: CGSize) -> CGSize {
  var imageSize = imageSize
  if imageSize.width > maxSize.width {
    imageSize.height /= imageSize.width/maxSize.width
    imageSize.width = maxSize.width
  }
  if imageSize.height > maxSize.height {
    imageSize.width /= imageSize.height/maxSize.height
    imageSize.height = maxSize.height
  }
  return imageSize
}

class HorizontalGalleryViewController: UIViewController {
  var images: [UIImage] = [
    UIImage(named: "l1")!,
    UIImage(named: "l2")!,
    UIImage(named: "l3")!,
    UIImage(named: "1")!,
    UIImage(named: "2")!,
    UIImage(named: "3")!,
    UIImage(named: "4")!,
    UIImage(named: "5")!,
    UIImage(named: "6")!,
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

  var collectionView = CollectionView()
  override func viewDidLoad() {
    super.viewDidLoad()

    let dataProvider = ArrayDataProvider(data: images)
    let viewProvider = ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
      view.image = data
      view.layer.cornerRadius = 5
      view.clipsToBounds = true
      view.yaal.rotation.setTo(CGFloat.random(-0.035, max: 0.035))
    })
    let layoutProvider = HorizontalWaterfallLayoutProvider(sizeProvider: { (_, data: UIImage, maxSize) in
      return sizeForImage(data.size, maxSize: maxSize)
    })

    let provider1 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layoutProvider: layoutProvider
    )
    let provider2 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layoutProvider: layoutProvider,
      presenter: WobblePresenter()
    )
    let provider3 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layoutProvider: layoutProvider,
      presenter: ZoomPresenter()
    )

    collectionView.provider = CollectionComposer([provider1, provider2, provider3], layoutProvider: HorizontalWaterfallLayoutProvider())
    view.addSubview(collectionView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length + 10, 10, 10, 10)
  }
}
