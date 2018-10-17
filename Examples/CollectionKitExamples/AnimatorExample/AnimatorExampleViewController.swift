//
//  AnimatorExampleViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class AnimatorExampleViewController: CollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let animators = [
      ("Default", Animator()),
      ("Wobble", WobbleAnimator()),
      ("Edge Shrink", EdgeShrinkAnimator()),
      ("Zoom", ZoomAnimator()),
      ]

    let imagesCollectionView = CollectionView()
    let visibleFrameInsets = UIEdgeInsets(top: 0, left: -100, bottom: 0, right: -100)

    let imageProvider = BasicProvider(
      dataSource: testImages,
      viewSource: ClosureViewSource(viewGenerator: { (data, index) -> UIImageView in
        let view = UIImageView()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
      }, viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
      }),
      sizeSource: UIImageSizeSource(),
      layout: WaterfallLayout(columns: 2, spacing: 10).transposed().inset(by: bodyInset).insetVisibleFrame(by: visibleFrameInsets),
      animator: animators[0].1
    )

    imagesCollectionView.provider = imageProvider

    let buttonsCollectionView = CollectionView()
    buttonsCollectionView.showsHorizontalScrollIndicator = false

    let buttonsProvider = BasicProvider(
      dataSource: animators,
      viewSource: { (view: SelectionButton, data: (String, Animator), at: Int) in
        view.label.text = data.0
        view.label.textColor = imageProvider.animator === data.1 ? .white : .black
        view.backgroundColor = imageProvider.animator === data.1 ? .lightGray : .white
      },
      sizeSource: { _, data, maxSize in
        return CGSize(width: data.0.width(withConstraintedHeight: maxSize.height, font: UIFont.systemFont(ofSize:18)) + 20, height: maxSize.height)
      },
      layout: FlowLayout(lineSpacing: 10).transposed()
        .inset(by: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)),
      animator: WobbleAnimator(),
      tapHandler: { context in
        imageProvider.animator = context.data.1

        // clear previous styles
        for cell in imagesCollectionView.visibleCells {
          cell.alpha = 1
          cell.transform = .identity
        }

        context.setNeedsReload()
      }
    )

    buttonsCollectionView.provider = buttonsProvider

    let buttonsViewProvider = SimpleViewProvider(
      views: [buttonsCollectionView],
      sizeStrategy: (.fill, .absolute(44))
    )
    let providerViewProvider = SimpleViewProvider(
      identifier: "providerContent",
      views: [imagesCollectionView],
      sizeStrategy: (.fill, .fill)
    )

    provider = ComposedProvider(
      layout: RowLayout("providerContent").transposed(),
      sections: [
        buttonsViewProvider,
        providerViewProvider
      ]
    )
  }
}
