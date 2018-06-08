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
    didSet { setNeedsReload() }
  }

  public var presenter: CollectionPresenter? {
    didSet { setNeedsReload() }
  }

  public var layout: CollectionLayout {
    didSet { setNeedsReload() }
  }

  public init(identifier: String? = nil,
              layout: CollectionLayout = FlowLayout(),
              presenter: CollectionPresenter? = nil,
              sections: [AnyCollectionProvider]) {
    self.presenter = presenter
    self.layout = layout
    self.sections = sections
    super.init(identifier: identifier)
  }

  public convenience init(identifier: String? = nil,
                          layout: CollectionLayout = FlowLayout(),
                          presenter: CollectionPresenter? = nil,
                          _ sections: AnyCollectionProvider...) {
    self.init(layout: layout, presenter: presenter, sections: sections)
  }

  open override var numberOfItems: Int {
    return sections.count
  }

  open override var hasSection: Bool {
    return true
  }

  open override func section(at: Int) -> AnyCollectionProvider? {
    return sections[at]
  }

  open override func view(at: Int) -> UIView {
    fatalError()
  }

  open override func update(view: UIView, at: Int) {
    fatalError()
  }

  open override func identifier(at: Int) -> String {
    return sections[at].identifier ?? "\(at)"
  }

  open override func layout(collectionSize: CGSize) {
    layout.layout(context: CollectionComposerLayoutContext(collectionSize: collectionSize,
                                                           sections: sections))
  }

  open override var contentSize: CGSize {
    return layout.contentSize
  }

  open override func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return layout.visibleIndexes(visibleFrame: visibleFrame)
  }

  open override func frame(at: Int) -> CGRect {
    return layout.frame(at: at)
  }

  open override func presenter(at: Int) -> CollectionPresenter? {
    fatalError()
  }

  open override func willReload() {
    super.willReload()
    for section in sections {
      section.willReload()
    }
  }

  open override func didReload() {
    super.didReload()
    for section in sections {
      section.didReload()
    }
  }

  open override func didTap(view: UIView, at: Int) {
    fatalError()
  }

  open override func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
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
