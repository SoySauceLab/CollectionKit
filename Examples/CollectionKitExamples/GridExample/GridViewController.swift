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
    let dataSource = ArrayDataSource(data: Array(1...kGridSize.width * kGridSize.height), identifierMapper: { (_, data) in
      return "\(data)"
    })
    let visibleFrameInsets = UIEdgeInsets(top: -150, left: -150, bottom: -150, right: -150)
    let layout = Closurelayout(frameProvider: { (i: Int, _) in
      CGRect(x: CGFloat(i % kGridSize.width) * (kGridCellSize.width + kGridCellPadding),
             y: CGFloat(i / kGridSize.width) * (kGridCellSize.height + kGridCellPadding),
             width: kGridCellSize.width,
             height: kGridCellSize.height)
    }).insetVisibleFrame(by: visibleFrameInsets)

    collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    provider = BasicProvider(
      dataSource: dataSource,
      viewSource: { (view: SquareView, data: Int, index: Int) in
        view.backgroundColor = UIColor(hue: CGFloat(index) / CGFloat(kGridSize.width * kGridSize.height),
                                       saturation: 0.68, brightness: 0.98, alpha: 1)
        view.text = "\(data)"
      },
      layout: layout,
      animator: WobbleAnimator()
    )
  }
}
