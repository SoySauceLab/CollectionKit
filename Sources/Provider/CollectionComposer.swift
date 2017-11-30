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
    didSet {
      setNeedsReload()
    }
  }

  fileprivate var sectionBeginIndex: [Int] = []
  fileprivate var sectionForIndex: [Int] = []

  fileprivate var currentSections: [AnyCollectionProvider] = []

  public var presenter: CollectionPresenter? { didSet { setNeedsReload() } }

  public var layout: CollectionLayout<AnyCollectionProvider> {
    didSet {
      setNeedsReload()
    }
  }

  public init(identifier: String? = nil,
              layout: CollectionLayout<AnyCollectionProvider> = FlowLayout(),
              presenter: CollectionPresenter? = nil,
              sections: [AnyCollectionProvider]) {
    self.sections = sections
    self.presenter = presenter
    self.layout = layout
    super.init(identifier: identifier)
  }

  public convenience init(identifier: String? = nil,
                          layout: CollectionLayout<AnyCollectionProvider> = FlowLayout(),
                          presenter: CollectionPresenter? = nil,
                          _ sections: AnyCollectionProvider...) {
    self.init(layout: layout, presenter: presenter, sections: sections)
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
    return currentSections[sectionIndex].view(at: item)
  }

  open override func update(view: UIView, at: Int) {
    let (sectionIndex, item) = indexPath(at)
    currentSections[sectionIndex].update(view: view, at: item)
  }

  open override func identifier(at: Int) -> String {
    let (sectionIndex, item) = indexPath(at)
    let sectionIdentifier = currentSections[sectionIndex].identifier ?? "\(sectionIndex)"
    return "\(sectionIdentifier)." + currentSections[sectionIndex].identifier(at: item)
  }

  open override func layout(collectionSize: CGSize) {
    layout.layout(
      collectionSize: collectionSize,
      dataProvider: ArrayDataProvider(data: currentSections, identifierMapper: {
       return $1.identifier ?? "\($0)"
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
      let sectionFrame = layout.frame(at: sectionIndex)
      let intersectFrame = activeFrame.intersection(sectionFrame)
      let activeFrameForCell = CGRect(origin: intersectFrame.origin - sectionFrame.origin, size: intersectFrame.size)
      let sectionVisible = currentSections[sectionIndex].visibleIndexes(activeFrame: activeFrameForCell)
      let beginIndex = sectionBeginIndex[sectionIndex]
      for item in sectionVisible {
        visible.append(item + beginIndex)
      }
    }
    return visible
  }

  open override func frame(at: Int) -> CGRect {
    let (sectionIndex, item) = indexPath(at)
    var frame = currentSections[sectionIndex].frame(at: item)
    frame.origin += layout.frame(at: sectionIndex).origin
    return frame
  }

  open override func presenter(at: Int) -> CollectionPresenter? {
    let (sectionIndex, item) = indexPath(at)
    return currentSections[sectionIndex].presenter(at: item) ?? presenter
  }

  open override func willReload() {
    super.willReload()
    for section in sections {
      section.willReload()
    }
    prepareForReload()
  }

  internal func prepareForReload() {
    currentSections = sections
    sectionBeginIndex = []
    sectionForIndex = []
    sectionBeginIndex.reserveCapacity(currentSections.count)
    for (sectionIndex, section) in currentSections.enumerated() {
      let itemCount = section.numberOfItems
      sectionBeginIndex.append(sectionForIndex.count)
      for _ in 0..<itemCount {
        sectionForIndex.append(sectionIndex)
      }
    }
  }

  open override func didReload() {
    super.didReload()
    for section in currentSections {
      section.didReload()
    }
  }

  open override func didTap(view: UIView, at: Int) {
    let (sectionIndex, item) = indexPath(at)
    currentSections[sectionIndex].didTap(view: view, at: item)
  }

  open override func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    if reloadable === self { return true }
    for section in currentSections {
      if section.hasReloadable(reloadable) {
        return true
      }
    }
    return false
  }

}
