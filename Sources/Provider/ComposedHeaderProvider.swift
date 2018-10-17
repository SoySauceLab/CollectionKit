//
//  ComposedHeaderProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-09.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import UIKit

public struct HeaderData {
  public let index: Int
  public let section: Provider
}

open class ComposedHeaderProvider<HeaderView: UIView>:
  SectionProvider, ItemProvider, LayoutableProvider, CollectionReloadable {

  public typealias HeaderViewSource = ViewSource<HeaderData, HeaderView>
  public typealias HeaderSizeSource = SizeSource<HeaderData>

  open var identifier: String?

  open var sections: [Provider] {
    didSet { setNeedsReload() }
  }

  open var animator: Animator? {
    didSet { setNeedsReload() }
  }

  open var headerViewSource: HeaderViewSource {
    didSet { setNeedsReload() }
  }

  open var headerSizeSource: HeaderSizeSource {
    didSet { setNeedsInvalidateLayout() }
  }

  open var layout: Layout {
    get { return stickyLayout.rootLayout }
    set {
      stickyLayout.rootLayout = newValue
      setNeedsInvalidateLayout()
    }
  }

  open var isSticky = true {
    didSet {
      if isSticky {
        stickyLayout.isStickyFn = { $0 % 2 == 0 }
      } else {
        stickyLayout.isStickyFn = { _ in false }
      }
      setNeedsReload()
    }
  }

  open var tapHandler: TapHandler?

  public typealias TapHandler = (TapContext) -> Void

  public struct TapContext {
    public let view: HeaderView
    public let index: Int
    public let section: Provider
  }

  private var stickyLayout: StickyLayout
  public var internalLayout: Layout { return stickyLayout }

  public init(identifier: String? = nil,
              layout: Layout = FlowLayout(),
              animator: Animator? = nil,
              headerViewSource: HeaderViewSource,
              headerSizeSource: HeaderSizeSource,
              sections: [Provider] = [],
              tapHandler: TapHandler? = nil) {
    self.animator = animator
    self.stickyLayout = StickyLayout(rootLayout: layout)
    self.sections = sections
    self.identifier = identifier
    self.headerViewSource = headerViewSource
    self.headerSizeSource = headerSizeSource
    self.tapHandler = tapHandler
  }

  open var numberOfItems: Int {
    return sections.count * 2
  }

  open func section(at: Int) -> Provider? {
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

  open func layoutContext(collectionSize: CGSize) -> LayoutContext {
    return ComposedHeaderProviderLayoutContext(
      collectionSize: collectionSize,
      sections: sections,
      headerSizeSource: headerSizeSource
    )
  }

  open func animator(at: Int) -> Animator? {
    return animator
  }

  open func view(at: Int) -> UIView {
    let index = at / 2
    return headerViewSource.view(data: HeaderData(index: index, section: sections[index]), index: index)
  }

  open func update(view: UIView, at: Int) {
    let index = at / 2
    headerViewSource.update(view: view as! HeaderView,
                              data: HeaderData(index: index, section: sections[index]),
                              index: index)
  }

  open func didTap(view: UIView, at: Int) {
    if let tapHandler = tapHandler {
      let index = at / 2
      let context = TapContext(view: view as! HeaderView, index: index, section: sections[index])
      tapHandler(context)
    }
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
    return reloadable === self || reloadable === headerSizeSource
      || sections.contains(where: { $0.hasReloadable(reloadable) })
  }

  open func flattenedProvider() -> ItemProvider {
    return FlattenedProvider(provider: self)
  }

  struct ComposedHeaderProviderLayoutContext: LayoutContext {
    var collectionSize: CGSize
    var sections: [Provider]
    var headerSizeSource: HeaderSizeSource

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
    func size(at index: Int, collectionSize: CGSize) -> CGSize {
      if index % 2 == 0 {
        return headerSizeSource.size(at: index / 2,
                                     data: data(at: index) as! HeaderData,
                                     collectionSize: collectionSize)
      } else {
        sections[index / 2].layout(collectionSize: collectionSize)
        return sections[index / 2].contentSize
      }
    }
  }
}
