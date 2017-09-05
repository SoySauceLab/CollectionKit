//
//  ReloadDataViewController.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

let maxDataCount: Int = 1000

class ReloadDataViewController: CollectionViewController {
  var data: [Int] = []
  var dataSet: Set<Int> = Set()

  let addButton: UIButton = {
    let button = UIButton()
    let addAttributedTitle =
        NSAttributedString(string: "+",
                           attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 20)])
    button.setTitleColor(.black, for: .normal)
    button.setAttributedTitle(addAttributedTitle, for: .normal)
    button.backgroundColor = UIColor(hue: 0.16, saturation: 0.68, brightness: 0.98, alpha: 1)
    return button
  }()

  let removeButton: UIButton = {
    let button = UIButton()
    let removeAttributedTitle =
      NSAttributedString(string: "-",
                         attributes: [NSFontAttributeName : UIFont.boldSystemFont(ofSize: 20)])
    button.setAttributedTitle(removeAttributedTitle, for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = UIColor(hue: 0.20, saturation: 0.68, brightness: 0.98, alpha: 1)
    return button
  }()

  let reloadButton: UIButton = {
    let button = UIButton()
    button.setTitle("Reset", for: .normal)
    button.setTitleColor(.black, for: .normal)
    button.backgroundColor = UIColor(hue: 0.22, saturation: 0.68, brightness: 0.98, alpha: 1)
    return button
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    addButton.addTarget(self, action: #selector(add), for: .touchUpInside)
    view.addSubview(addButton)
    removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
    view.addSubview(removeButton)
    reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
    view.addSubview(reloadButton)

    let dataProvider = ArrayDataProvider(data: data, identifierMapper: { (_, data) in
      return "\(data)"
    })
    let layout = FlowLayout<Int>(insets: UIEdgeInsetsMake(15, 15, 15, 15),
                                 lineSpacing: 15,
                                 interitemSpacing: 15)
    let presenter = ZoomPresenter()
    presenter.insertAnimation = .scale
    presenter.deleteAnimation = .scale
    provider = CollectionProvider(
      dataProvider: dataProvider,
      viewUpdater: { (view: UILabel, data: Int, index: Int) in
        view.backgroundColor = UIColor(hue: CGFloat(data) / CGFloat(maxDataCount),
                                       saturation: 0.68,
                                       brightness: 0.98,
                                       alpha: 1)
        view.textColor = .white
        view.textAlignment = .center
        view.text = "\(data)"
      },
      layout: layout,
      sizeProvider: { _, _, _ in
        return CGSize(width: 60, height: 60)
      },
      presenter: presenter
    )
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    let viewWidth = view.bounds.width
    let viewHeight = view.bounds.height
    addButton.frame = CGRect(x: 0, y: 0, width: 80, height: 44)
    removeButton.frame = CGRect(x: viewWidth - 80, y: 0, width: 80, height: 44)
    reloadButton.frame = CGRect(x: 80, y: 0, width: viewWidth - 80 * 2, height: 44)
    collectionView.frame = CGRect(x: 0, y: 44, width: viewWidth, height: viewHeight - 44)
  }
}

extension ReloadDataViewController {
  private func updateDataProvider() {
    if let collectionProvider = provider as? CollectionProvider<Int, UILabel> {
      collectionProvider.dataProvider =
        ArrayDataProvider(data: data, identifierMapper: { (_, data) in
          return "\(data)"
        })
    }
  }

  private func addNewData(count: Int) {
    guard count > 0, count < maxDataCount else {
      return
    }
    var currentCount = count
    while currentCount > 0 {
      var new = Int.random(maxDataCount)
      while dataSet.contains(new) {
        new = Int.random(maxDataCount)
      }
      data.append(new)
      dataSet.insert(new)
      currentCount -= 1
    }
  }

  func add() {
    guard data.count < maxDataCount else {
      return
    }
    self.addNewData(count: 1)
    self.updateDataProvider()
    // NOTE: Call reloadData() directly will make collectionView update immediately, so that contentSize
    // of collectionView will be updated.
    collectionView.reloadData()
    collectionView.scrollTo(edge: .bottom, animated:true)
  }

  func remove() {
    guard data.count > 0 else {
      return
    }
    let removed = data.removeLast()
    dataSet.remove(removed)
    self.updateDataProvider()
  }

  func reload() {
    dataSet.removeAll()
    data.removeAll()
    let newCount = Int.random(30)
    self.addNewData(count: newCount)
    self.updateDataProvider()
  }
}
