//
//  MoveManager.swift
//  CollectionKit
//
//  Created by Luke on 3/20/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit
import YetAnotherAnimationLibrary

class CollectionDragContext: NSObject {
  var gesture: UILongPressGestureRecognizer
  var cell: UIView
  var collectionView: CollectionView

  var startingLocationDiffInCell: CGPoint
  var canReorder = true

  init(gesture: UILongPressGestureRecognizer, cell: UIView, in collectionView: CollectionView) {
    self.gesture = gesture
    self.cell = cell
    self.collectionView = collectionView
    startingLocationDiffInCell = gesture.location(in: cell) - cell.bounds.center
    super.init()

    gesture.addTarget(self, action: #selector(handleLongPress(gestureRecognizer:)))
  }

  func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
    guard gestureRecognizer == gesture, gesture.state == .changed else { return }

    if let index = collectionView.index(for: cell) {
      let location = gestureRecognizer.location(in: collectionView.overlayView)
      cell.yaal.center.setTo(location - startingLocationDiffInCell)

      var scrollVelocity = CGPoint.zero

      if collectionView.contentSize.width > collectionView.bounds.size.width {
        if location.x < collectionView.absoluteFrameLessInset.minX + 80,
          collectionView.contentOffset.x > collectionView.offsetFrame.minX {
          scrollVelocity.x = -(collectionView.absoluteFrameLessInset.minX + 80 - location.x) * 20
        } else if location.x > collectionView.absoluteFrameLessInset.maxX - 80,
          collectionView.contentOffset.x < collectionView.offsetFrame.maxX {
          scrollVelocity.x = (location.x - (collectionView.absoluteFrameLessInset.maxX - 80)) * 20
        }
      }
      if collectionView.contentSize.height > collectionView.bounds.size.height {
        if location.y < collectionView.absoluteFrameLessInset.minY + 80,
          collectionView.contentOffset.y > collectionView.offsetFrame.minY {
          scrollVelocity.y = -(collectionView.absoluteFrameLessInset.minY + 80 - location.y) * 20
        } else if location.y > collectionView.absoluteFrameLessInset.maxY - 80,
          collectionView.contentOffset.y < collectionView.offsetFrame.maxY {
          scrollVelocity.y = (location.y - (collectionView.absoluteFrameLessInset.maxY - 80)) * 20
        }
      }

      if scrollVelocity == .zero {
        collectionView.yaal.contentOffset.decay(damping: 5)
      } else {
        collectionView.yaal.contentOffset.decay(initialVelocity: scrollVelocity, damping: 0)
      }

      if scrollVelocity == .zero,
        canReorder,
        !collectionView.isDragging,
        let toIndex = collectionView.indexForCell(at: gestureRecognizer.location(in: collectionView)),
        toIndex != index,
        collectionView.provider?.moveItem(at: index, to: toIndex) == true
      {
        canReorder = false
        delay(0.1) {
          self.canReorder = true
        }
        collectionView.reloadData()
      }
    }
  }
}

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
        collectionView.provider?.willDrag(cell: cell, at: index) == true {
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
          collectionView.provider?.didDrag(cell: cell, at: index)
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
