//
//  EmptyStateCollectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-08-08.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public class EmptyStateCollectionProvider: CollectionComposer {
  var emptyStateView: UIView?
  var emptyStateViewGetter: () -> UIView
  var content: AnyCollectionProvider

  public init(identifier: String? = nil, emptyStateView: @autoclosure @escaping () -> UIView, content: AnyCollectionProvider) {
    self.emptyStateViewGetter = emptyStateView
    self.content = content
    super.init(identifier: identifier, layout: FlexLayout(flex: ["emptyStateView": FlexValue(flex: 1)]), [content])
  }

  public override func willReload() {
    if content.numberOfItems == 0, sections.first === content {
      if emptyStateView == nil {
        emptyStateView = emptyStateViewGetter()
      }
      let viewSection = ViewCollectionProvider(emptyStateView!, sizeStrategy: (.fill, .fill))
      viewSection.identifier = "emptyStateView"
      sections = [viewSection]
    } else if content.numberOfItems > 0, sections.first !== content {
      sections = [content]
    }
    super.willReload()
  }
}
