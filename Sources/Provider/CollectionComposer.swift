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
    get { return dataProvider.data }
    set { dataProvider.data = newValue }
  }

  public var presenter: CollectionPresenter? {
    didSet {
      setNeedsReload()
    }
  }

  public var layout: CollectionLayout<AnyCollectionProvider> {
    didSet {
      setNeedsReload()
    }
  }

  private var sectionBeginIndex: [Int] = []
  private var dataProvider: ArrayDataProvider<AnyCollectionProvider>

  public init(identifier: String? = nil,
              layout: CollectionLayout<AnyCollectionProvider> = FlowLayout(),
              presenter: CollectionPresenter? = nil,
              sections: [AnyCollectionProvider]) {
    self.presenter = presenter
    self.layout = layout
    self.dataProvider = ArrayDataProvider(data: sections, identifierMapper: {
      return $1.identifier ?? "\($0)"
    })
    super.init(identifier: identifier)
  }

  public convenience init(identifier: String? = nil,
                          layout: CollectionLayout<AnyCollectionProvider> = FlowLayout(),
                          presenter: CollectionPresenter? = nil,
                          _ sections: AnyCollectionProvider...) {
    self.init(layout: layout, presenter: presenter, sections: sections)
  }

  func indexPath(_ index: Int) -> (Int, Int) {
    let sectionIndex = sectionBeginIndex.binarySearch { $0 <= index } - 1
    return (sectionIndex, index - sectionBeginIndex[sectionIndex])
  }

  open override var numberOfItems: Int {
    return (sectionBeginIndex.last ?? 0) + (sections.last?.numberOfItems ?? 0)
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
    layout.layout(
      collectionSize: collectionSize,
      dataProvider: dataProvider,
      sizeProvider: { (_, data, collectionSize) in
        data.layout(collectionSize: collectionSize)
        return data.contentSize
      })
  }

  open override var contentSize: CGSize {
    return layout.contentSize
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    var visible = [Int]()
    for sectionIndex in layout.visibleIndexes(visibleFrame: visibleFrame) {
      let sectionFrame = layout.frame(at: sectionIndex)
      let intersectFrame = visibleFrame.intersection(sectionFrame)
      let visibleFrameForCell = CGRect(origin: intersectFrame.origin - sectionFrame.origin, size: intersectFrame.size)
      let sectionVisible = sections[sectionIndex].visibleIndexes(visibleFrame: visibleFrameForCell)
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
    frame.origin += layout.frame(at: sectionIndex).origin
    return frame
  }

  open override func presenter(at: Int) -> CollectionPresenter? {
    let (sectionIndex, item) = indexPath(at)
    return sections[sectionIndex].presenter(at: item) ?? presenter
  }

  open override func willReload() {
    super.willReload()
    for section in sections {
      section.willReload()
    }
    prepareForReload()
  }

  internal func prepareForReload() {
    sectionBeginIndex = []
    sectionBeginIndex.reserveCapacity(sections.count)
    var count = 0
    for section in sections {
      sectionBeginIndex.append(count)
      count += section.numberOfItems
    }
  }

  open override func didReload() {
    super.didReload()
    for section in sections {
      section.didReload()
    }
  }

  open override func didTap(view: UIView, at: Int) {
    let (sectionIndex, item) = indexPath(at)
    sections[sectionIndex].didTap(view: view, at: item)
  }

  open override func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || reloadable === dataProvider ||
      sections.contains(where: { $0.hasReloadable(reloadable) })
  }
}
