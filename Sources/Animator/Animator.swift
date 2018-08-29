//
//  CollectionAnimator.swift
//  CollectionView
//
//  Created by Luke Zhao on 2017-07-19.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class Animator {

  /// Called when CollectionView inserts a view into its subviews.
  ///
  /// Perform any insertion animation when needed
  ///
  /// - Parameters:
  ///   - collectionView: source CollectionView
  ///   - view: the view being inserted
  ///   - at: index of the view inside the CollectionView (after flattening step)
  ///   - frame: frame provided by the layout
  open func insert(collectionView: CollectionView,
                   view: UIView,
                   at: Int,
                   frame: CGRect) {
    view.bounds.size = frame.bounds.size
    view.center = frame.center
  }

  /// Called when CollectionView deletes a view from its subviews.
  ///
  /// Perform any deletion animation, then call `view.recycleForCollectionKitReuse()`
  /// after the animation finishes
  ///
  /// - Parameters:
  ///   - collectionView: source CollectionView
  ///   - view: the view being deleted
  open func delete(collectionView: CollectionView,
                   view: UIView) {
    view.recycleForCollectionKitReuse()
  }

  /// Called when:
  ///   * the view has just been inserted
  ///   * the view's frame changed after `reloadData`
  ///   * the view's screen position changed when user scrolls
  ///
  /// - Parameters:
  ///   - collectionView: source CollectionView
  ///   - view: the view being updated
  ///   - at: index of the view inside the CollectionView (after flattening step)
  ///   - frame: frame provided by the layout
  open func update(collectionView: CollectionView,
                   view: UIView,
                   at: Int,
                   frame: CGRect) {
    if view.bounds.size != frame.bounds.size {
      view.bounds.size = frame.bounds.size
    }
    if view.center != frame.center {
      view.center = frame.center
    }
  }

  /// Called when contentOffset changes during reloadData
  ///
  /// - Parameters:
  ///   - collectionView: source CollectionView
  ///   - delta: changes in contentOffset
  ///   - view: the view being updated
  ///   - at: index of the view inside the CollectionView (after flattening step)
  ///   - frame: frame provided by the layout
  open func shift(collectionView: CollectionView,
                  delta: CGPoint,
                  view: UIView,
                  at: Int,
                  frame: CGRect) {
    view.center += delta
  }

  public init() {}
}
