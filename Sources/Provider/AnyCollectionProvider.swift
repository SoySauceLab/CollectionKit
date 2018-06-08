//
//  AnyCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-23.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public protocol AnyCollectionProvider: ViewOnlyCollectionProvider, CollectionReloadable {
  var hasSection: Bool { get }
  func section(at: Int) -> AnyCollectionProvider?
}

public protocol ViewOnlyCollectionProvider {
  var identifier: String? { get }

  // data
  var numberOfItems: Int { get }
  func identifier(at: Int) -> String

  // view
  func view(at: Int) -> UIView
  func update(view: UIView, at: Int)

  // layout
  func layout(collectionSize: CGSize)

  func visibleIndexes(visibleFrame: CGRect) -> [Int]
  var contentSize: CGSize { get }
  func frame(at: Int) -> CGRect

  // event
  func willReload()
  func didReload()
  func didTap(view: UIView, at: Int)

  func presenter(at: Int) -> CollectionPresenter?

  // determines if a context belongs to current provider
  func hasReloadable(_ reloadable: CollectionReloadable) -> Bool
}

extension AnyCollectionProvider {
  func flattenedProvider() -> ViewOnlyCollectionProvider {
    if hasSection {
      return ComposedSectionData(provider: self)
    } else {
      return self
    }
  }
}

struct ComposedSectionData: ViewOnlyCollectionProvider {

  var provider: AnyCollectionProvider

  private var childSections: [(beginIndex: Int, sectionData: ViewOnlyCollectionProvider?)]

  init(provider: AnyCollectionProvider) {
    self.provider = provider
    var childSections: [(beginIndex: Int, sectionData: ViewOnlyCollectionProvider?)] = []
    childSections.reserveCapacity(provider.numberOfItems)
    var count = 0
    for i in 0..<provider.numberOfItems {
      let sectionData: ViewOnlyCollectionProvider?
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

  func apply<T>(_ index: Int, with: (ViewOnlyCollectionProvider, Int) -> T) -> T {
    let (sectionIndex, item) = indexPath(index)
    if let sectionData = childSections[sectionIndex].sectionData {
      return with(sectionData, item)
    } else {
      return with(provider, sectionIndex)
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

  func presenter(at: Int) -> CollectionPresenter? {
    return apply(at) {
      $0.presenter(at: $1)
    }
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
