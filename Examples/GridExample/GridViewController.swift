//
//  GridViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2016-06-05.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

let kGridCellSize = CGSize(width: 50, height: 50)
let kGridSize = (width: 20, height: 20)
let kGridCellPadding:CGFloat = 10

class GridViewController: CollectionViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let dataProvider = ArrayDataProvider(data: Array(1...kGridSize.width * kGridSize.height), identifierMapper: { (_, data) in
      return "\(data)"
    })
    let layout = Closurelayout(
      frameProvider: { (i: Int, data: Int,  _) in
        CGRect(x: CGFloat(i % kGridSize.width) * (kGridCellSize.width + kGridCellPadding),
               y: CGFloat(i / kGridSize.width) * (kGridCellSize.height + kGridCellPadding),
               width: kGridCellSize.width,
               height: kGridCellSize.height)
      }
    )

    collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let provider = CollectionProvider(
      dataProvider: dataProvider,
      viewUpdater: { (view: UILabel, data: Int, index: Int) in
        view.backgroundColor = UIColor(hue: CGFloat(index) / CGFloat(kGridSize.width * kGridSize.height),
                                       saturation: 0.68, brightness: 0.98, alpha: 1)
        view.textColor = .white
        view.textAlignment = .center
        view.text = "\(data)"
      }
    )
    provider.layout = layout
    provider.presenter = WobblePresenter()
    self.provider = provider
  }

}
