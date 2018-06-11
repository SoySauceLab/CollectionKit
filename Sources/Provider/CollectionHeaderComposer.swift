//
//  CollectionHeaderComposer.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-09.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

open class CollectionHeaderComposer<HeaderView: UIView>: SectionSource, ViewSource, CollectionReloadable {

  public typealias HeaderData = (index: Int, section: AnyCollectionProvider)
  public typealias HeaderViewProvider = CollectionViewProvider<HeaderData, HeaderView>
  public typealias HeaderSizeProvider = CollectionSizeProvider<HeaderData>

  public var identifier: String?

  public var sections: [AnyCollectionProvider] {
    didSet { setNeedsReload() }
  }

  public var presenter: CollectionPresenter? {
    didSet { setNeedsReload() }
  }

  public var headerViewProvider: HeaderViewProvider {
    didSet { setNeedsReload() }
  }

  public var headerSizeProvider: HeaderSizeProvider {
    didSet { setNeedsReload() }
  }

  public var layout: CollectionLayout {
    get { return internalLayout.rootLayout }
    set {
      internalLayout.rootLayout = newValue
      setNeedsReload()
    }
  }

  public var isSticky = true {
    didSet {
      if isSticky {
        internalLayout.isStickyFn = { $0 % 2 == 0 }
      } else {
        internalLayout.isStickyFn = { _ in false }
      }
      setNeedsReload()
    }
  }

  private var internalLayout: StickyLayout

  public init(identifier: String? = nil,
              layout: CollectionLayout = FlowLayout(),
              presenter: CollectionPresenter? = nil,
              headerViewProvider: HeaderViewProvider,
              headerSizeProvider: @escaping HeaderSizeProvider,
              sections: [AnyCollectionProvider]) {
    self.presenter = presenter
    self.internalLayout = StickyLayout(rootLayout: layout)
    self.sections = sections
    self.identifier = identifier
    self.headerViewProvider = headerViewProvider
    self.headerSizeProvider = headerSizeProvider
  }

  open var numberOfItems: Int {
    return sections.count * 2
  }

  open func section(at: Int) -> AnyCollectionProvider? {
    if at % 2 == 0 {
      return nil
    } else {
      return sections[at / 2]
    }
  }

  open func identifier(at: Int) -> String {
    let sectionIdentifier = sections[at / 2].identifier ?? "\(at)"
    if at % 2 == 0 {
      return sectionIdentifier + "-header"
    } else {
      return sectionIdentifier
    }
  }

  open func layout(collectionSize: CGSize) {
    internalLayout.layout(context:
      CollectionHeaderComposerLayoutContext(
        collectionSize: collectionSize,
        sections: sections,
        headerViewProvider: headerViewProvider,
        headerSizeProvider: headerSizeProvider
    ))
  }

  open var contentSize: CGSize {
    return internalLayout.contentSize
  }

  open func visibleIndexes(visibleFrame: CGRect) -> [Int] {
    return internalLayout.visibleIndexes(visibleFrame: visibleFrame)
  }

  open func frame(at: Int) -> CGRect {
    return internalLayout.frame(at: at)
  }

  open func presenter(at: Int) -> CollectionPresenter? {
    return presenter
  }

  public func view(at: Int) -> UIView {
    let index = at / 2
    return headerViewProvider.view(data: HeaderData(index: index, section: sections[index]), index: index)
  }

  public func update(view: UIView, at: Int) {
    let index = at / 2
    headerViewProvider.update(view: view as! HeaderView,
                              data: HeaderData(index: index, section: sections[index]),
                              index: index)
  }

  public func didTap(view: UIView, at: Int) {
    // TODO: CollectionHeaderProvider doesn't support tap yet
    // Need to cleanup tapHandler first.
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

  // MARK: private stuff
  open func hasReloadable(_ reloadable: CollectionReloadable) -> Bool {
    return reloadable === self || sections.contains(where: { $0.hasReloadable(reloadable) })
  }

  open func flattenedProvider() -> ViewSource {
    return FlattenedProvider(provider: self)
  }

  struct CollectionHeaderComposerLayoutContext: LayoutContext {
    var collectionSize: CGSize
    var sections: [AnyCollectionProvider]
    var headerViewProvider: HeaderViewProvider
    var headerSizeProvider: HeaderSizeProvider

    var numberOfItems: Int {
      return sections.count * 2
    }
    func data(at: Int) -> Any {
      if at % 2 == 0 {
        return HeaderData(index: at / 2, section: sections[at / 2])
      } else {
        return sections[at / 2]
      }
    }
    func identifier(at: Int) -> String {
      let sectionIdentifier = sections[at / 2].identifier ?? "\(at)"
      if at % 2 == 0 {
        return sectionIdentifier + "-header"
      } else {
        return sectionIdentifier
      }
    }
    func size(at: Int, collectionSize: CGSize) -> CGSize {
      if at % 2 == 0 {
        return headerSizeProvider(at / 2, data(at: at) as! HeaderData, collectionSize)
      } else {
        sections[at / 2].layout(collectionSize: collectionSize)
        return sections[at / 2].contentSize
      }
    }
  }
}
