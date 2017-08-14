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

class GridViewController: UIViewController {

  var collectionView: CollectionView!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
    view.clipsToBounds = true
    collectionView = CollectionView(frame:view.bounds)
    view.addSubview(collectionView)

    let dataProvider = ArrayDataProvider(data: Array(1...kGridSize.width * kGridSize.height), identifierMapper: { (_, data) in
      return "\(data)"
    })
    let viewProvider = ClosureViewProvider(viewUpdater: { (view: UILabel, data: Int, at: Int) in
      view.backgroundColor = UIColor.lightGray
      view.text = "\(data)"
    })
    let layout = Closurelayout(frameProvider: { (i: Int, data: Int,  _) in
      CGRect(x: CGFloat(i % kGridSize.width) * (kGridCellSize.width + kGridCellPadding),
             y: CGFloat(i / kGridSize.width) * (kGridCellSize.height + kGridCellPadding),
             width: kGridCellSize.width,
             height: kGridCellSize.height)
    })

    collectionView.provider = CollectionProvider(
      dataProvider: dataProvider,
      viewProvider: viewProvider,
      layout: layout,
      presenter: WobblePresenter(),
      willDragHandler: { _, _, _ in return true },
      moveHandler: { from, to, dataProvider in
        guard let dataProvider = dataProvider as? ArrayDataProvider<Int> else { return false }
        dataProvider.data.insert(dataProvider.data.remove(at: from), at: to)
        return true
      }
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    collectionView.frame = view.bounds
    collectionView.contentInset = UIEdgeInsetsMake(topLayoutGuide.length, 0, 0, 0)
  }
}

