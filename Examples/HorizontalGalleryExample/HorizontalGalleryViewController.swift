//
//  HorizontalGalleryViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2016-06-14.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

func imageSizeProvider(at: Int, data: UIImage, collectionSize: CGSize) -> CGSize {
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

class HorizontalGalleryViewController: CollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
    provider = CollectionProvider(
      data: testImages,
      viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
      },
      layout: WaterfallLayout<UIImage>(columns: 2).transposed(),
      sizeProvider: imageSizeProvider,
      presenter: WobblePresenter()
    )
  }

}
