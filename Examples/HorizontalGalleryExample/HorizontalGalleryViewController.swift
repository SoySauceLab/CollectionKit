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
    let provider = CollectionProvider(data: testImages, viewGenerator: { (data, index) -> UIImageView in
      let view = UIImageView()
      view.layer.cornerRadius = 5
      view.clipsToBounds = true
      return view
    }, viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
      view.image = data
    })
    provider.layout = WaterfallLayout<UIImage>(columns: 2).transposed()
    provider.sizeProvider = imageSizeProvider
    provider.presenter = WobblePresenter()
    self.provider = provider
  }

}
