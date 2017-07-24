//
//  CoreConceptSection.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

let coreConceptSection: AnyCollectionProvider = {
  let concepts: [(String, String)] = [
    ("Data Provider", "The data source for the collection. It provides a homogenious set of data. The data will be passed to view provider, layout provider, and responder."),
    ("View Provider", "Provides corresponding UIView object for each of the data provided by the data source."),
    ("Layout Provider", "Provides layout information for the collection view."),
    ("Size Provider", "Provides size information to the layout provider."),
    ("Responder", "Provides event handler to the collection view events like tap, drag, & reload."),
    ("Presenter", "Can be used to customize the presentation of the child views. It is independent of the layout and have direct access to the view object. It is the perfect place to add animations to an existing provider.")
  ]
  let collectionView = CollectionView()
  collectionView.provider = CollectionProvider(
    dataProvider: ArrayDataProvider(data: testImages),
    viewProvider: ClosureViewProvider(viewUpdater: { (view: UIImageView, data: UIImage, at: Int) in
      view.image = data
      view.layer.cornerRadius = 5
      view.clipsToBounds = true
    }),
    layout: WaterfallLayout<UIImage>(insets: bodyInset, axis: .horizontal),
    sizeProvider: ImageSizeProvider()
  )

  return section(title: "Core Concepts", content: ViewCollectionProvider(collectionView, sizeStrategy: .fillWidth(height: 400)))
}()
