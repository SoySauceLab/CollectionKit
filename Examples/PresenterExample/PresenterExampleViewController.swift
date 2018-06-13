//
//  PresenterExampleViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class PresenterExampleViewController: CollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let presenters = [
      ("Default", Presenter()),
      ("Wobble", WobblePresenter()),
      ("Edge Shrink", EdgeShrinkPresenter()),
      ("Zoom", ZoomPresenter()),
      ]

    let imagesCollectionView = CollectionView()
    let visibleFrameInsets = UIEdgeInsets(top: 0, left: -100, bottom: 0, right: -100)
    let imageProvider = BasicProviderBuilder
      .with(data: testImages)
      .with(viewGenerator: { (data, index) -> UIImageView in
        let view = UIImageView()
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
      }, viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
      })
      .with(layout: WaterfallLayout(columns:2).transposed().inset(by: bodyInset).insetVisibleFrame(by: visibleFrameInsets))
      .with(sizeSource: imageSizeProvider)
      .with(presenter: presenters[0].1)
      .build()

    imagesCollectionView.provider = imageProvider

    let buttonsCollectionView = CollectionView()
    buttonsCollectionView.showsHorizontalScrollIndicator = false

    let buttonsProvider = BasicProviderBuilder
      .with(data: presenters)
      .with(viewUpdater: { (view: SelectionButton, data: (String, Presenter), at: Int) in
        view.label.text = data.0
        view.label.textColor = imageProvider.presenter === data.1 ? .white : .black
        view.backgroundColor = imageProvider.presenter === data.1 ? .lightGray : .white
      })
      .with(layout: FlowLayout(lineSpacing: 10).transposed()
        .inset(by: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16)))
      .with(sizeSource: { _, data, maxSize in
        return CGSize(width: data.0.width(withConstraintedHeight: maxSize.height, font: UIFont.systemFont(ofSize:18)) + 20, height: maxSize.height)
      })
      .with(presenter: WobblePresenter())
      .with(tapHandler: { context in
        imageProvider.presenter = context.data.1

        // clear previous styles
        for cell in imagesCollectionView.visibleCells {
          cell.alpha = 1
          cell.transform = .identity
        }

        context.setNeedsReload()
      }).build()

    buttonsCollectionView.provider = buttonsProvider

    let buttonsCollectionViewProvider = SimpleViewProvider(
      views: [buttonsCollectionView],
      sizeStrategy: (.fill, .absolute(44))
    )
    let providerCollectionViewProvider = SimpleViewProvider(
      identifier: "providerContent",
      views: [imagesCollectionView],
      sizeStrategy: (.fill, .fill)
    )

    provider = ComposedProvider(
      layout: RowLayout("providerContent").transposed(),
      sections: [
        buttonsCollectionViewProvider,
        providerCollectionViewProvider
      ]
    )
  }
}
