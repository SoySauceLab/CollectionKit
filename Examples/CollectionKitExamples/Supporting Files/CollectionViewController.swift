//
//  CollectionViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class CollectionViewController: UIViewController {
  let collectionView = CollectionView()

  var provider: Provider? {
    get { return collectionView.provider }
    set { collectionView.provider = newValue }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
  }
}
