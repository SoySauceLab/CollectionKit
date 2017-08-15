//
//  MoveManager.swift
//  CollectionKit
//
//  Created by Luke on 3/20/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import YetAnotherAnimationLibrary

class CollectionDragManager: NSObject {
  weak var collectionView: CollectionView? {
    didSet {
      addNextLongPressGesture()
    }
  }

  var contexts: [UILongPressGestureRecognizer: CollectionDragContext] = [:]

  func addNextLongPressGesture() {
    if let collectionView = collectionView {
      let nextLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
      nextLongPressGestureRecognizer.delegate = self
      nextLongPressGestureRecognizer.minimumPressDuration = 0.5
      collectionView.addGestureRecognizer(nextLongPressGestureRecognizer)
    }
  }

  func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    guard let collectionView = collectionView else { return }
    switch gestureRecognizer.state {
    case .began:
      if let index = collectionView.indexForCell(at: gestureRecognizer.location(in: collectionView)),
        let cell = collectionView.cell(at: index),
        !collectionView.isFloating(cell: cell),
        collectionView.provider.willDrag(view: cell, at: index) == true {
        addNextLongPressGesture()
        collectionView.panGestureRecognizer.isEnabled = false
        collectionView.panGestureRecognizer.isEnabled = true
        collectionView.float(cell: cell)
        contexts[gestureRecognizer] = CollectionDragContext(gesture: gestureRecognizer, cell: cell, in: collectionView)
      } else {
        gestureRecognizer.isEnabled = false
        gestureRecognizer.isEnabled = true
      }
      break
    case .changed:
      break
    default:
      gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
      collectionView.yaal.contentOffset.decay(damping: 5)
      if let moveContext = contexts[gestureRecognizer] {
        contexts[gestureRecognizer] = nil
        let cell = moveContext.cell
        if let index = collectionView.index(for: cell), collectionView.isFloating(cell: cell) {
          collectionView.unfloat(cell: cell)
          collectionView.provider.didDrag(view: cell, at: index)
        }
      }
      break
    }
  }
}

extension CollectionDragManager: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return otherGestureRecognizer == collectionView?.panGestureRecognizer || otherGestureRecognizer.delegate === self
  }
}
