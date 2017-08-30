//
//  CollectionComposer.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionComposer: BaseCollectionProvider {
  public var sections: [AnyCollectionProvider] {
    didSet{
      setNeedsReload()
    }
  }

  fileprivate var sectionBeginIndex:[Int] = []
  fileprivate var sectionForIndex:[Int] = []

  fileprivate var lastReloadSections: [AnyCollectionProvider]?
  fileprivate var lastSectionBeginIndex: [Int]?
  fileprivate var lastSectionForIndex: [Int]?

  public var presenter: CollectionPresenter? { didSet { setNeedsReload() } }
  public var layout: CollectionLayout<AnyCollectionProvider> {
    didSet {
      setNeedsReload()
    }
  }

  public init(identifier: String? = nil,
              layout: CollectionLayout<AnyCollectionProvider> = FlowLayout(),
              presenter: CollectionPresenter? = nil,
              _ sections: [AnyCollectionProvider]) {
    self.sections = sections
    self.layout = layout
    super.init(identifier: identifier)
  }

  public convenience init(identifier: String? = nil,
                          layout: CollectionLayout<AnyCollectionProvider> = FlowLayout(),
                          presenter: CollectionPresenter? = nil,
                          _ sections: AnyCollectionProvider...) {
    self.init(layout: layout, sections)
  }

  func indexPath(_ index: Int) -> (Int, Int) {
    let section = sectionForIndex[index]
    let item = index - sectionBeginIndex[section]
    return (section, item)
  }

  open override var numberOfItems: Int {
    return sectionForIndex.count
  }
  open override func view(at: Int) -> UIView {
    let (sectionIndex, item) = indexPath(at)
    return sections[sectionIndex].view(at: item)
  }
  open override func update(view: UIView, at: Int) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].update(view: view, at: item)
  }
  open override func identifier(at: Int) -> String {
    let (sectionIndex, item) = indexPath(at)
    let sectionIdentifier = sections[sectionIndex].identifier ?? "\(sectionIndex)"
    return "\(sectionIdentifier)." + sections[sectionIndex].identifier(at: item)
  }
  open override func layout(collectionSize: CGSize) {
    layout._layout(
      collectionSize: collectionSize,
      dataProvider: ArrayDataProvider(data: sections, identifierMapper: {
       return $0.1.identifier ?? "\($0.0)"
      }),
      sizeProvider: { (_, data, collectionSize) in
        data.layout(collectionSize: collectionSize)
        return data.contentSize
      })
  }
  open override var contentSize: CGSize {
    return layout.contentSize
  }
  open override func visibleIndexes(activeFrame: CGRect) -> [Int] {
    var visible = [Int]()
    for sectionIndex in layout.visibleIndexes(activeFrame: activeFrame) {
      let sectionOrigin = layout.frame(at: sectionIndex).origin
      let sectionVisible = sections[sectionIndex].visibleIndexes(activeFrame: CGRect(origin: activeFrame.origin - sectionOrigin, size: activeFrame.size))
      let beginIndex = sectionBeginIndex[sectionIndex]
      for item in sectionVisible {
        visible.append(item + beginIndex)
      }
    }
    return visible
  }
  open override func frame(at: Int) -> CGRect {
    let (sectionIndex, item) = indexPath(at)
    var frame = sections[sectionIndex].frame(at: item)
    frame.origin = frame.origin + layout.frame(at: sectionIndex).origin
    return frame
  }

  open override func presenter(at: Int) -> CollectionPresenter? {
    let (sectionIndex, item) = indexPath(at)
    return sections[sectionIndex].presenter(at: item) ?? presenter
  }

  open override func willReload() {
    lastSectionForIndex = sectionForIndex
    lastSectionBeginIndex = sectionBeginIndex
    lastReloadSections = sections
    for section in sections {
      section.willReload()
    }
    sectionBeginIndex = []
    sectionForIndex = []
    sectionBeginIndex.reserveCapacity(sections.count)
    for (sectionIndex, section) in sections.enumerated() {
      let itemCount = section.numberOfItems
      sectionBeginIndex.append(sectionForIndex.count)
      for _ in 0..<itemCount {
        sectionForIndex.append(sectionIndex)
      }
    }
  }
  open override func didReload() {
    for section in sections {
      section.didReload()
    }
    lastSectionForIndex = nil
    lastSectionBeginIndex = nil
  }
  open override func didTap(view: UIView, at: Int) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].didTap(view: view, at: item)
  }
  
  open override func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    if reloadable === self { return true }
    for section in sections {
      if section.hasReloadable(reloadable) {
        return true
      }
    }
    return false
  }
}
