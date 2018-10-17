//
//  ComposedHeaderProvider+Convenience.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-10-15.
//

extension ComposedHeaderProvider {
  public convenience init(identifier: String? = nil,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          headerViewSource: @escaping ViewUpdaterFn<HeaderData, HeaderView>,
                          headerSizeSource: @escaping ClosureSizeSourceFn<HeaderData>,
                          sections: [Provider] = [],
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              layout: layout,
              animator: animator,
              headerViewSource: ClosureViewSource(viewUpdater: headerViewSource),
              headerSizeSource: ClosureSizeSource(sizeSource: headerSizeSource),
              sections: sections,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          headerViewSource: HeaderViewSource,
                          headerSizeSource: @escaping ClosureSizeSourceFn<HeaderData>,
                          sections: [Provider] = [],
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              layout: layout,
              animator: animator,
              headerViewSource: headerViewSource,
              headerSizeSource: ClosureSizeSource(sizeSource: headerSizeSource),
              sections: sections,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          headerViewSource: @escaping ViewUpdaterFn<HeaderData, HeaderView>,
                          headerSizeSource: HeaderSizeSource,
                          sections: [Provider] = [],
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              layout: layout,
              animator: animator,
              headerViewSource: ClosureViewSource(viewUpdater: headerViewSource),
              headerSizeSource: headerSizeSource,
              sections: sections,
              tapHandler: tapHandler)
  }
}
