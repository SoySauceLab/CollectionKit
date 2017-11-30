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

public class CollectionReuseViewManager: NSObject {
  var reusableViews: [String: [UIView]] = [:]
  var cleanupTimer: Timer?
  public var lifeSpan: TimeInterval = 0.5

  public func queue(view: UIView) {
    let identifier = String(describing: type(of: view))
    view.reuseManager = nil
    if reusableViews[identifier] != nil && !reusableViews[identifier]!.contains(view) {
      reusableViews[identifier]?.append(view)
    } else {
      reusableViews[identifier] = [view]
    }
    cleanupTimer?.invalidate()
    cleanupTimer = Timer.scheduledTimer(timeInterval: lifeSpan, target: self,
                                        selector: #selector(cleanup), userInfo: nil, repeats: false)
  }

  public func dequeue<T: UIView> (_ defaultView: @autoclosure () -> T) -> T {
    let queuedView = reusableViews[String(describing: T.self)]?.popLast() as? T
    let view = queuedView ?? defaultView()
    if let view = view as? CollectionViewReusableView {
      view.prepareForReuse()
    }
    view.reuseManager = self
    return view
  }

  @objc func cleanup() {
    reusableViews.removeAll()
  }
}
