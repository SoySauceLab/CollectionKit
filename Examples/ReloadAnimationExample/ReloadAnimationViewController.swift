//
//  ReloadAnimationViewController.swift
//  CollectionKitExample
//
//  Created by Luke Zhao on 2017-12-14.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import CollectionKit

class AnimatedReloadPresenter: CollectionPresenter {
  static let defaultEntryTransform: CATransform3D = CATransform3DTranslate(CATransform3DScale(CATransform3DIdentity, 0.8, 0.8, 1), 0, 0, -1)
  static let fancyEntryTransform: CATransform3D = {
    var trans = CATransform3DIdentity
    trans.m34 = -1 / 500
    return CATransform3DScale(CATransform3DRotate(CATransform3DTranslate(trans, 0, -50, -100), 0.5, 1, 0, 0), 0.8, 0.8, 1)
  }()

  let entryTransform: CATransform3D

  init(entryTransform: CATransform3D = defaultEntryTransform) {
    self.entryTransform = entryTransform
    super.init()
  }

  override func delete(collectionView: CollectionView, view: UIView) {
    if collectionView.reloading, collectionView.bounds.intersects(view.frame) {
      UIView.animate(withDuration: 0.25, animations: {
        view.layer.transform = self.entryTransform
        view.alpha = 0
      }, completion: { _ in
        if !collectionView.visibleCells.contains(view) {
          view.recycleForCollectionKitReuse()
          view.transform = CGAffineTransform.identity
          view.alpha = 1
        }
      })
    } else {
      view.recycleForCollectionKitReuse()
    }
  }

  override func insert(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    view.bounds = frame.bounds
    view.center = frame.center
    if collectionView.reloading, collectionView.hasReloaded, collectionView.bounds.intersects(frame) {
      let offsetTime: TimeInterval = TimeInterval(frame.origin.distance(collectionView.contentOffset) / 3000)
      view.layer.transform = entryTransform
      view.alpha = 0
      UIView.animate(withDuration: 0.5, delay: offsetTime, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
        view.transform = .identity
        view.alpha = 1
      })
    }
  }

  override func update(collectionView: CollectionView, view: UIView, at: Int, frame: CGRect) {
    if view.center != frame.center {
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.layoutSubviews], animations: {
        view.center = frame.center
      }, completion: nil)
    }
    if view.bounds.size != frame.bounds.size {
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [.layoutSubviews], animations: {
        view.bounds.size = frame.bounds.size
      }, completion: nil)
    }
    if view.alpha != 1 || view.transform != .identity {
      UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
        view.transform = .identity
        view.alpha = 1
      }, completion: nil)
    }
  }
}

class ReloadAnimationViewController: CollectionViewController {

  let dataProvider = ArrayDataProvider<Int>(data: []) { (_, data) in
    return "\(data)"
  }

  let reloadButton: UIButton = {
    let button = UIButton()
    button.setTitle("Reload", for: .normal)
    button.titleLabel?.font = .boldSystemFont(ofSize: 20)
    button.backgroundColor = UIColor(hue: 0.6, saturation: 0.68, brightness: 0.98, alpha: 1)
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: -12)
    button.layer.shadowRadius = 10
    button.layer.shadowOpacity = 0.1
    return button
  }()

  var currentDataIndex = 0
  var data: [[Int]] = [
    [],
    [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18],
    [2,3,5,8,10],
    [8,9,10,11,12,13,14,15,16],
  ]

  override func viewDidLoad() {
    super.viewDidLoad()
    reloadButton.addTarget(self, action: #selector(reload), for: .touchUpInside)
    view.addSubview(reloadButton)

    collectionView.contentInset = UIEdgeInsetsMake(20, 10, 20, 10)
    let layout = FlowLayout<Int>(lineSpacing: 15,
                                 interitemSpacing: 15,
                                 justifyContent: .spaceAround,
                                 alignItems: .center,
                                 alignContent: .center)
    let presenter = AnimatedReloadPresenter(entryTransform: AnimatedReloadPresenter.fancyEntryTransform)
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
      return CGSize(width: 80, height: 80)
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
    reloadButton.frame = CGRect(x: 0, y: viewHeight - 44, width: viewWidth, height: 44)
    collectionView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight - 44)
  }

  @objc func reload() {
    currentDataIndex = (currentDataIndex + 1) % data.count
    dataProvider.data = data[currentDataIndex]
  }
}


