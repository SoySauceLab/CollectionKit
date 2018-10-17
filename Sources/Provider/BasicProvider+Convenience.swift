//
//  BasicProvider+Convenience.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-10-15.
//

extension BasicProvider {
  public convenience init(identifier: String? = nil,
                          dataSource: DataSource<Data>,
                          viewSource: @escaping ViewUpdaterFn<Data, View>,
                          sizeSource: SizeSource<Data>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: dataSource,
              viewSource: ClosureViewSource(viewUpdater: viewSource),
              sizeSource: sizeSource,
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: DataSource<Data>,
                          viewSource: ViewSource<Data, View>,
                          sizeSource: @escaping ClosureSizeSourceFn<Data>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: dataSource,
              viewSource: viewSource,
              sizeSource: ClosureSizeSource(sizeSource: sizeSource),
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: DataSource<Data>,
                          viewSource: @escaping ViewUpdaterFn<Data, View>,
                          sizeSource: @escaping ClosureSizeSourceFn<Data>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: dataSource,
              viewSource: ClosureViewSource(viewUpdater: viewSource),
              sizeSource: ClosureSizeSource(sizeSource: sizeSource),
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: [Data],
                          viewSource: ViewSource<Data, View>,
                          sizeSource: SizeSource<Data>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: ArrayDataSource(data: dataSource),
              viewSource: viewSource,
              sizeSource: sizeSource,
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: [Data],
                          viewSource: @escaping ViewUpdaterFn<Data, View>,
                          sizeSource: SizeSource<Data>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: ArrayDataSource(data: dataSource),
              viewSource: ClosureViewSource(viewUpdater: viewSource),
              sizeSource: sizeSource,
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: [Data],
                          viewSource: ViewSource<Data, View>,
                          sizeSource: @escaping ClosureSizeSourceFn<Data>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: ArrayDataSource(data: dataSource),
              viewSource: viewSource,
              sizeSource: ClosureSizeSource(sizeSource: sizeSource),
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: [Data],
                          viewSource: @escaping ViewUpdaterFn<Data, View>,
                          sizeSource: @escaping ClosureSizeSourceFn<Data>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: ArrayDataSource(data: dataSource),
              viewSource: ClosureViewSource(viewUpdater: viewSource),
              sizeSource: ClosureSizeSource(sizeSource: sizeSource),
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: [Data],
                          viewSource: @escaping ViewUpdaterFn<Data, View>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: ArrayDataSource(data: dataSource),
              viewSource: ClosureViewSource(viewUpdater: viewSource),
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: [Data],
                          viewSource: ViewSource<Data, View>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: ArrayDataSource(data: dataSource),
              viewSource: viewSource,
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }

  public convenience init(identifier: String? = nil,
                          dataSource: DataSource<Data>,
                          viewSource: @escaping ViewUpdaterFn<Data, View>,
                          layout: Layout = FlowLayout(),
                          animator: Animator? = nil,
                          tapHandler: TapHandler? = nil) {
    self.init(identifier: identifier,
              dataSource: dataSource,
              viewSource: ClosureViewSource(viewUpdater: viewSource),
              layout: layout,
              animator: animator,
              tapHandler: tapHandler)
  }
}
