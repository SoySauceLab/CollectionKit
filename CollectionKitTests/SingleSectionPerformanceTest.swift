//
//  PerformanceTest.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-12-03.
//  Copyright © 2018 lkzhao. All rights reserved.
//

@testable import CollectionKit
import XCTest

class SingleSectionPerformanceTest: XCTestCase {
  var collectionView: CollectionView!

  override func setUp() {
    collectionView = CollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 1000))
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    let dataSource = ArrayDataSource(data: Array(0..<100000))
    let provider = BasicProvider(
      dataSource: dataSource,
      viewSource: { (label: UILabel, data: Int, index: Int) in },
      sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
        return CGSize(width: 50, height: 50)
    })
    collectionView.provider = provider
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
    collectionView.reloadData()
    measure {
      for _ in 0..<1000 {
        collectionView.bounds.origin.y += 10
        collectionView.layoutSubviews()
      }
    }
  }

}
