//
//  CollectionReuseViewManager.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-21.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol CollectionViewReusableView: class {
  func prepareForReuse()
}

public class CollectionReuseViewManager {
  public static let shared = CollectionReuseViewManager()

  var reusableViews: [String:[UIView]] = [:]
  var cleanupTimer: Timer?

  public func queue(view: UIView) {
    let identifier = String(describing: type(of: view))
    if reusableViews[identifier] != nil && !reusableViews[identifier]!.contains(view) {
      reusableViews[identifier]?.append(view)
    } else {
      reusableViews[identifier] = [view]
    }
    cleanupTimer?.invalidate()
    cleanupTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(cleanup), userInfo: nil, repeats: false)
  }
  
  public func dequeue<T: UIView> (_ viewClass: T.Type) -> T {
    let cell = reusableViews[String(describing: viewClass)]?.popLast() as? T ?? T()
    if let cell = cell as? CollectionViewReusableView {
      cell.prepareForReuse()
    }
    return cell
  }
  
  @objc func cleanup() {
    reusableViews.removeAll()
  }
}
