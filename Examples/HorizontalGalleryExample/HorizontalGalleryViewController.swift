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


class HorizontalGalleryViewController: UIViewController, UIScrollViewDelegate {

  var collectionView = CollectionView()
  let images = testImages

  override func viewDidLoad() {
    super.viewDidLoad()

    let dataProvider = ArrayDataProvider(data: images)
    let viewProvider = ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
      view.image = data
      view.layer.cornerRadius = 5
      view.clipsToBounds = true
    })
    let layout = WaterfallLayout<UIImage>(axis: .horizontal)
    let sizeProvider = ImageSizeProvider()

    let provider1 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layout: layout,
      sizeProvider: sizeProvider
    )
    let provider2 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layout: layout,
      sizeProvider: sizeProvider,
      presenter: WobblePresenter()
    )
    let provider3 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layout: layout,
      sizeProvider: sizeProvider,
      presenter: ZoomPresenter()
    )
    let provider4 = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layout: layout,
      sizeProvider: sizeProvider,
      presenter: EdgeShrinkPresenter()
    )

    collectionView.provider = CollectionComposer(layout: WaterfallLayout(axis: .horizontal), provider1, provider2, provider3, provider4)
    view.addSubview(collectionView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length + 10, 10, 10, 10)
  }
}
