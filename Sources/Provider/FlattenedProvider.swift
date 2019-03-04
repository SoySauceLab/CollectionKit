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
      return provider.identifier(at: sectionIndex) + "-" + sectionData.identifier(at: item)
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

  func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    var visible = [Int]()
    for sectionIndex in provider.visibleIndexes(visibleFrame: visibleFrame) {
      let beginIndex = childSections[sectionIndex].beginIndex
      if let sectionData = childSections[sectionIndex].sectionData {
        let sectionFrame = provider.frame(at: sectionIndex)
        let intersectFrame = visibleFrame.intersection(sectionFrame)
        let visibleFrameForCell = CGRect(origin: intersectFrame.origin - sectionFrame.origin, size: intersectFrame.size)
        let sectionVisible = sectionData.visibleIndexes(visibleFrame: visibleFrameForCell)
        for item in sectionVisible {
          visible.append(item + beginIndex)
        }
      } else {
        visible.append(beginIndex)
      }
    }
    return visible
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
