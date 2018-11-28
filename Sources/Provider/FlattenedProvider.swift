//
//  FlattenedProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-08.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

struct FlattenedProvider: ItemProvider {

  var provider: SectionProvider

  private var childSections: [(beginIndex: Int, sectionData: ItemProvider?)]

  init(provider: SectionProvider) {
    self.provider = provider
    var childSections: [(beginIndex: Int, sectionData: ItemProvider?)] = []
    childSections.reserveCapacity(provider.numberOfItems)
    var count = 0
    for i in 0..<provider.numberOfItems {
      let sectionData: ItemProvider?
      if let section = provider.section(at: i) {
        sectionData = section.flattenedProvider()
      } else {
        sectionData = nil
      }
      childSections.append((beginIndex: count, sectionData: sectionData))
      count += sectionData?.numberOfItems ?? 1
    }
    self.childSections = childSections
  }

  func indexPath(_ index: Int) -> (Int, Int) {
    let sectionIndex = childSections.binarySearch { $0.beginIndex <= index } - 1
    return (sectionIndex, index - childSections[sectionIndex].beginIndex)
  }

  func apply<T>(_ index: Int, with: (ItemProvider, Int) -> T) -> T {
    let (sectionIndex, item) = indexPath(index)
    if let sectionData = childSections[sectionIndex].sectionData {
      return with(sectionData, item)
    } else {
      assert(provider is ItemProvider, "Provider don't support view index")
      return with(provider as! ItemProvider, sectionIndex)
    }
  }

  var identifier: String? {
    return provider.identifier
  }

  var numberOfItems: Int {
    return (childSections.last?.beginIndex ?? 0) + (childSections.last?.sectionData?.numberOfItems ?? 0)
  }

  func view(at: Int) -> UIView {
    return apply(at) {
      $0.view(at: $1)
    }
  }

  func update(view: UIView, at: Int) {
    return apply(at) {
      $0.update(view: view, at: $1)
    }
  }

  func identifier(at: Int) -> String {
    let (sectionIndex, item) = indexPath(at)
    if let sectionData = childSections[sectionIndex].sectionData {
      return provider.identifier(at: sectionIndex) + sectionData.identifier(at: item)
    } else {
      return provider.identifier(at: sectionIndex)
    }
  }

  func layout(collectionSize: CGSize) {
    provider.layout(collectionSize: collectionSize)
  }

  var contentSize: CGSize {
    return provider.contentSize
  }

  func visible(for visibleFrame: CGRect) -> (indexes: [Int], frame: CGRect)  {
    let visible = provider.visible(for: visibleFrame)
    // sort child sections by the indexes from layout
    let sections = Array(0..<childSections.count).sorted(by: visible.indexes)
    // load indexes from all child sections
    let indexes = sections.flatMap { index -> [Int] in
      let sectionFrame = provider.frame(at: index)
      let intersectFrame = visible.frame.intersection(sectionFrame)
      var visibleFrameForCell = CGRect(origin: intersectFrame.origin - sectionFrame.origin, size: intersectFrame.size)
      if intersectFrame.origin == .infinity {
        // even if there is no intersection now, there might be
        // after the childs layout adds visible frame inset so
        // we still call the section with a valid frame
        visibleFrameForCell.origin = visible.frame.origin
      }
      let child = childSections[index]
      let childVisible = child.sectionData?.visible(for: visibleFrameForCell)
      let childIndexes = childVisible?.indexes ?? [0]
      return childIndexes.map { $0 + child.beginIndex }
    }
    return (indexes, visible.frame)
  }

  func frame(at: Int) -> CGRect {
    let (sectionIndex, item) = indexPath(at)
    if let sectionData = childSections[sectionIndex].sectionData {
      var frame = sectionData.frame(at: item)
      frame.origin += provider.frame(at: sectionIndex).origin
      return frame
    } else {
      return provider.frame(at: sectionIndex)
    }
  }

  func animator(at: Int) -> Animator? {
    return apply(at) {
      $0.animator(at: $1)
    } ?? provider.animator(at: at)
  }

  func willReload() {
    provider.willReload()
  }

  func didReload() {
    provider.didReload()
  }

  func didTap(view: UIView, at: Int) {
    return apply(at) {
      $0.didTap(view: view, at: $1)
    }
  }

  func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return provider.hasReloadable(reloadable)
  }
}

extension CGPoint {
  static var infinity: CGPoint = CGPoint(x: CGFloat.infinity, y: CGFloat.infinity)
}

extension Array where Element: Equatable {
  
  /// Returns an array sorted based on another array
  ///
  /// - Parameter array: The array with items that we sort bt
  /// - Returns: An array sorted by elements in parameter array.
  func sorted(by array: [Element]) -> [Element] {
    return array.filter { contains($0) } + filter { !array.contains($0) }
  }
}
