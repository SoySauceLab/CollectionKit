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

    let visibleFrameInsets = UIEdgeInsets(top: 0, left: -100, bottom: 0, right: -100)
    provider = BasicProvider(
      dataSource: ArrayDataSource(data: testImages),
      viewSource: ClosureViewSource(viewGenerator: { (data, index) -> UIImageView in
        let view = UIImageView()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
      }, viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
      }),
      sizeSource: imageSizeProvider,
      layout: WaterfallLayout(columns: 2, spacing: 10).transposed().insetVisibleFrame(by: visibleFrameInsets),
      animator: WobbleAnimator()
    )
  }

}
