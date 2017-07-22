//
//  CollectionComposer.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class CollectionComposer<LayoutProvider> where LayoutProvider: CustomSizeLayoutProvider<AnyCollectionProvider> {
  public var sections: [AnyCollectionProvider]

  fileprivate var sectionBeginIndex:[Int] = []
  fileprivate var sectionForIndex:[Int] = []
  fileprivate var sectionFrames:[[CGRect]] = []
  fileprivate var sectionFrameOrigin:[CGPoint] = []

  var layoutProvider: LayoutProvider

  public init(_ sections: [AnyCollectionProvider] = [], layoutProvider: LayoutProvider) {
    self.sections = sections
    self.layoutProvider = layoutProvider
    self.layoutProvider.sizeProvider = { [weak self] (index, section, size) -> CGSize in
      guard let strongSelf = self else { return .zero }
      var sectionUnionFrame: CGRect = .zero
      strongSelf.sectionFrames.append([])
      section.prepareLayout(maxSize: size)
      for i in 0..<section.numberOfItems {
        let frame = section.frame(at: i)
        strongSelf.sectionFrames[index].append(frame)
        sectionUnionFrame = sectionUnionFrame.union(frame)
      }
      return sectionUnionFrame.size
    }
  }

  public convenience init(_ sections: AnyCollectionProvider..., layoutProvider: LayoutProvider) {
    self.init(sections, layoutProvider: layoutProvider)
  }

  func indexPath(_ index: Int) -> (Int, Int) {
    let section = sectionForIndex[index]
    let item = index - sectionBeginIndex[section]
    return (section, item)
  }

  func insets(for index: Int) -> UIEdgeInsets {
    if let section = sections.get(index) {
      return section.insets
    }
    return .zero
  }
}

extension CollectionComposer: AnyCollectionProvider {
  public var insets: UIEdgeInsets {
    return layoutProvider.insets
  }
  public var numberOfItems: Int {
    return sectionForIndex.count
  }
  public func view(at: Int) -> UIView {
    let (sectionIndex, item) = indexPath(at)
    return sections[sectionIndex].view(at: item)
  }
  public func update(view: UIView, at: Int) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].update(view: view, at: item)
  }
  public func identifier(at: Int) -> String {
    let (sectionIndex, item) = indexPath(at)
    return "section-\(sectionIndex)-" + sections[sectionIndex].identifier(at: item)
  }

  public func prepareLayout(maxSize: CGSize) {
    sectionFrames = []
    sectionFrameOrigin = []
    layoutProvider.prepareLayout(maxSize: maxSize)
    for (i, section) in sections.enumerated() {
      sectionFrameOrigin.append(layoutProvider.frame(with: section, at: i).origin)
    }
  }
  public func frame(at: Int) -> CGRect {
    let (sectionIndex, item) = indexPath(at)
    var frame = sectionFrames[sectionIndex][item]
    frame.origin = frame.origin + sectionFrameOrigin[sectionIndex]
    return frame
  }
  public func willReload() {
    for section in sections {
      section.willReload()
    }
    sectionBeginIndex.removeAll()
    sectionForIndex.removeAll()
    sectionBeginIndex.reserveCapacity(sections.count)
    for (sectionIndex, section) in sections.enumerated() {
      let itemCount = section.numberOfItems
      sectionBeginIndex.append(sectionForIndex.count)
      for _ in 0..<itemCount {
        sectionForIndex.append(sectionIndex)
      }
    }
  }
  public func didReload() {
    for section in sections {
      section.didReload()
    }
  }
  public func willDrag(cell: UIView, at index:Int) -> Bool {
    let (sectionIndex, item) = indexPath(index)
    return sections[sectionIndex].willDrag(cell: cell, at: item)
  }
  public func didDrag(cell: UIView, at index:Int) {
    let (sectionIndex, item) = indexPath(index)
    sections[sectionIndex].didDrag(cell: cell, at: item)
  }
  public func moveItem(at index: Int, to: Int) -> Bool {
    let (fromSection, fromItem) = indexPath(index)
    let (toSection, toItem) = indexPath(to)
    if fromSection == toSection {
      return sections[fromSection].moveItem(at: fromItem, to: toItem)
    }
    return false
  }
  public func didTap(cell: UIView, at: Int) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].didTap(cell: cell, at: item)
  }
  public func prepareForPresentation(collectionView: CollectionView) {
    for section in sections {
      section.prepareForPresentation(collectionView: collectionView)
    }
  }
  public func shift(delta: CGPoint) {
    for section in sections {
      section.shift(delta: delta)
    }
  }
  public func insert(view: UIView, at: Int, frame: CGRect) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].insert(view: view, at: item, frame: frame)
  }
  public func delete(view: UIView, at: Int, frame: CGRect) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].delete(view: view, at: item, frame: frame)
  }
  public func update(view: UIView, at: Int, frame: CGRect) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].update(view: view, at: item, frame: frame)
  }
}
