//
//  ComposedSectionPerformanceTest.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-12-03.
//  Copyright © 2018 lkzhao. All rights reserved.
//

@testable import CollectionKit
import XCTest

class ComposedSectionPerformanceTest: XCTestCase {
  var collectionView: CollectionView!

  override func setUp() {
    collectionView = CollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 1000))
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false

    let sections: [ComposedProvider] = (0..<10).map { _ in
      let sections: [Provider] = (0..<100).map { _ in
        let viewSource = ClosureViewSource<Int, UIView>(viewUpdater: { _, _, _ in })
        viewSource.reuseManager.removeFromCollectionViewWhenReuse = true
        return BasicProvider(dataSource: Array(0..<100), viewSource: viewSource,
                             sizeSource: { _, _, _ in return CGSize(width: 100, height: 100) })
      }
      return ComposedProvider(sections: sections)
    }
    let provider = ComposedProvider(layout: RowLayout().transposed(), sections: sections)
    collectionView.provider = provider
    collectionView.reloadData()
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testReloadPerformance() {
    measure {
      collectionView.reloadData()
    }
  }

  func testVisibleIndexesPerformance() {
    measure {
      for _ in 0..<1000 {
        collectionView.bounds.origin.y += 100
        _ = collectionView.provider!.visibleIndexes(visibleFrame: collectionView.bounds)
      }
    }
  }

  func testScrollPerformance() {
    measure {
      for _ in 0..<1000 {
        collectionView.bounds.origin.y += 100
        collectionView.layoutSubviews()
      }
    }
  }

}
