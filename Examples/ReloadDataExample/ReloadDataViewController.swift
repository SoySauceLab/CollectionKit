//
//  ReloadDataViewController.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class ReloadDataViewController: CollectionViewController {

  let dataProvider = ArrayDataProvider<Int>(data: Array(0..<5)) { (_, data) in
    return "\(data)"
  }

  let addButton: UIButton = {
    let button = UIButton()
    button.setTitle("+", for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: 20)
    button.backgroundColor = UIColor(hue: 0.6, saturation: 0.68, brightness: 0.98, alpha: 1)
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: -12)
    button.layer.shadowRadius = 10
    button.layer.shadowOpacity = 0.1
    return button
  }()

  var currentMax: Int = 5

  override func viewDidLoad() {
    super.viewDidLoad()
    addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
    view.addSubview(addButton)

    collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10)
    let layout = FlowLayout<Int>(lineSpacing: 15,
                                 interitemSpacing: 15,
                                 justifyContent: .spaceAround,
                                 alignItems: .center,
                                 alignContent: .center)
    let presenter = CollectionPresenter()
    presenter.insertAnimation = .scale
    presenter.deleteAnimation = .scale
    presenter.updateAnimation = .normal
    let provider = CollectionProvider(
      dataProvider: dataProvider,
      viewUpdater: { (view: UILabel, data: Int, index: Int) in
        view.backgroundColor = UIColor(hue: CGFloat(data) / 30,
                                       saturation: 0.68,
                                       brightness: 0.98,
                                       alpha: 1)
        view.textColor = .white
        view.textAlignment = .center
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.text = "\(data)"
      }
    )
    provider.layout = layout
    provider.sizeProvider = { (index, data, _) in
      return CGSize(width: 80, height: data % 3 == 0 ? 120 : 80)
    }
    provider.presenter = presenter
    provider.tapHandler = { [weak self] (view, index, _) in
      self?.dataProvider.data.remove(at: index)
    }
    self.provider = provider
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let viewWidth = view.bounds.width
    let viewHeight = view.bounds.height
    addButton.frame = CGRect(x: 0, y: viewHeight - 44, width: viewWidth, height: 44)
    collectionView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight - 44)
  }

  @objc func add() {
    dataProvider.data.append(currentMax)
    currentMax += 1
    // NOTE: Call reloadData() directly will make collectionView update immediately, so that contentSize
    // of collectionView will be updated.
    collectionView.reloadData()
    collectionView.scrollTo(edge: .bottom, animated:true)
  }
}

