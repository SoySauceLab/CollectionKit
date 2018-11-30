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
      let section = provider.frame(at: index)
      // intersection that doesn't return invalid frame when the
      // rects don't intersect but rather returns a rect spanning
      // the part of the border of the visible frame where the
      // section frame would enter the visible frame if it
      // were closer. This allows for the section to add its
      // visible inset to that rect and show according to that.
      // Calculation source https://math.stackexchange.com/a/99576
      let x = max(0, visible.frame.origin.x - section.origin.x)
      let y = max(0, visible.frame.origin.y - section.origin.y)
      let maxTop = max(visible.frame.origin.y, section.origin.y)
      let maxLeft = max(visible.frame.origin.x, section.origin.x)
      let minBottom = min(visible.frame.origin.y + visible.frame.size.height, section.origin.y + section.size.height)
      let minRight = min(visible.frame.origin.x + visible.frame.size.width, section.origin.x + section.size.width)
      let visibleFrameForCell = CGRect(x: x, y: y, width: minRight - maxLeft, height: minBottom - maxTop)
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
