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
      ("Default", CollectionPresenter()),
      ("Wobble", WobblePresenter()),
      ("Edge Shrink", EdgeShrinkPresenter()),
      ("Zoom", ZoomPresenter()),
      ]
    let imagesCollectionView = CollectionView()
    let imageProvider = CollectionProvider(
      data: testImages,
      viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
        view.image = data
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
      }
    )
    imageProvider.layout = WaterfallLayout(columns:2).transposed().inset(by: bodyInset)
    imageProvider.sizeProvider = imageSizeProvider
    imageProvider.presenter = presenters[0].1
    imagesCollectionView.provider = imageProvider
    imagesCollectionView.activeFrameInset = UIEdgeInsets(top: 0, left: -100, bottom: 0, right: -100)

    let buttonsCollectionView = CollectionView()
    buttonsCollectionView.showsHorizontalScrollIndicator = false
    let buttonsProvider = CollectionProvider(
      data: presenters,
      viewUpdater: { (view: SelectionButton, data: (String, CollectionPresenter), at: Int) in
        view.label.text = data.0
        view.label.textColor = imageProvider.presenter === data.1 ? .white : .black
        view.backgroundColor = imageProvider.presenter === data.1 ? .lightGray : .white
      }
    )
    buttonsProvider.layout = FlowLayout(lineSpacing: 10).transposed().inset(by: UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16))
    buttonsProvider.sizeProvider = { _, data, maxSize in
      return CGSize(width: data.0.width(withConstraintedHeight: maxSize.height, font: UIFont.systemFont(ofSize:18)) + 20, height: maxSize.height)
    }
    buttonsProvider.presenter = WobblePresenter()
    buttonsProvider.tapHandler = { _, index, dataProvider in
      imageProvider.presenter = dataProvider.data(at: index).1

      // clear previous styles
      for cell in imagesCollectionView.visibleCells {
        cell.alpha = 1
        cell.transform = .identity
      }

      dataProvider.reloadData()
    }

    buttonsCollectionView.provider = buttonsProvider

    let buttonsCollectionViewProvider = ViewCollectionProvider(buttonsCollectionView, sizeStrategy: (.fill, .absolute(44)))
    let providerCollectionViewProvider = ViewCollectionProvider(identifier: "providerContent", imagesCollectionView, sizeStrategy: (.fill, .fill))

    provider = CollectionComposer(
      layout: RowLayout("providerContent").transposed(),
      buttonsCollectionViewProvider,
      providerCollectionViewProvider
    )
  }
}
