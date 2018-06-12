//
//  CollectionComposer.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-20.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

open class CollectionComposer: SectionProviderType, CollectionReloadable {

  public var identifier: String?

  public var sections: [AnyCollectionProvider] {
    didSet { setNeedsReload() }
  }

  public var presenter: Presenter? {
    didSet { setNeedsReload() }
  }

  public var layout: Layout {
    didSet { setNeedsReload() }
  }

  public init(identifier: String? = nil,
              layout: Layout = FlowLayout(),
              presenter: Presenter? = nil,
              sections: [AnyCollectionProvider]) {
    self.presenter = presenter
    self.layout = layout
    self.sections = sections
    self.identifier = identifier
  }

  public convenience init(identifier: String? = nil,
                          layout: Layout = FlowLayout(),
                          presenter: Presenter? = nil,
                          _ sections: AnyCollectionProvider...) {
    self.init(identifier: identifier, layout: layout, presenter: presenter, sections: sections)
  }

  open var numberOfItems: Int {
    return sections.count
  }

  open func section(at: Int) -> AnyCollectionProvider? {
    return sections[at]
  }

  open func identifier(at: Int) -> String {
    return sections[at].identifier ?? "\(at)"
  }

  open func layout(collectionSize: CGSize) {
    layout.layout(context: CollectionComposerLayoutContext(collectionSize: collectionSize,
                                                           sections: sections))
  }

  open var contentSize: CGSize {
    return layout.contentSize
  }

  open func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return layout.visibleIndexes(visibleFrame: visibleFrame)
  }

  open func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }

  open func presenter(at: Int) -> Presenter? {
    return presenter
  }

  open func willReload() {
    for section in sections {
      section.willReload()
    }
  }

  open func didReload() {
    for section in sections {
      section.didReload()
    }
  }

  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || sections.contains(where: { $0.hasReloadable(reloadable) })
  }
}

struct CollectionComposerLayoutContext: LayoutContext {
  var collectionSize: CGSize
  var sections: [AnyCollectionProvider]

  var numberOfItems: Int {
    return sections.count
  }
  func data(at: Int) -> Any {
    return sections[at]
  }
  func identifier(at: Int) -> String {
    return sections[at].identifier ?? "\(at)"
  }
  func size(at: Int, collectionSize: CGSize) -> CGSize {
    sections[at].layout(collectionSize: collectionSize)
    return sections[at].contentSize
  }
}
