//
//  GridViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2016-06-05.
//  Copyright © 2016 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

let kGridCellSize = CGSize(width: 100, height: 100)
let kGridSize = (width: 20, height: 20)
let kGridCellPadding:CGFloat = 10

class GridViewController: CollectionViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    let dataProvider = ArrayDataProvider(data: Array(1...kGridSize.width * kGridSize.height), identifierMapper: { (_, data) in
      return "\(data)"
    })
    let layout = Closurelayout(frameProvider: { (i: Int, data: Int,  _) in
      CGRect(x: CGFloat(i % kGridSize.width) * (kGridCellSize.width + kGridCellPadding),
             y: CGFloat(i / kGridSize.width) * (kGridCellSize.height + kGridCellPadding),
             width: kGridCellSize.width,
             height: kGridCellSize.height)
    })

    provider = CollectionProvider(
      dataProvider: dataProvider,
      viewUpdater: { (view: UILabel, data: Int, at: Int) in
        view.backgroundColor = UIColor.lightGray
        view.text = "\(data)"
      },
      layout: layout,
      presenter: WobblePresenter()
    )
  }

}
