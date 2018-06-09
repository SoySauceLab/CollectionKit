//
//  HeaderExampleViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2018-06-09.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class HeaderExampleViewController: CollectionViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    let sections: [AnyCollectionProvider] = (1...10).map { _ in
      return CollectionProvider(
        data: Array(1...9),
        viewUpdater: { (view: UILabel, data: Int, index: Int) in
          view.backgroundColor = UIColor(hue: CGFloat(index) / 10,
                                         saturation: 0.68, brightness: 0.98, alpha: 1)
          view.textColor = .white
          view.textAlignment = .center
          view.text = "\(data)"
        },
        layout: FlowLayout(spacing: 10, justifyContent: .center, alignItems: .center)
          .inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
        sizeProvider: { (index, data, maxSize) -> CGSize in
          return CGSize(width: 100, height: 100)
        }
      )
    }

    let provider = CollectionHeaderComposer(
      headerViewProvider: ClosureViewProvider(
        viewUpdater: { (view: UILabel, data: (index: Int, section: AnyCollectionProvider), index) in
          view.backgroundColor = UIColor.darkGray
          view.textColor = .white
          view.textAlignment = .center
          view.text = "Header \(index)"
      }),
      headerSizeProvider: { (index, data, maxSize) -> CGSize in
        return CGSize(width: maxSize.width, height: 40)
      },
      sections: sections
    )

    self.provider = provider
  }

}
