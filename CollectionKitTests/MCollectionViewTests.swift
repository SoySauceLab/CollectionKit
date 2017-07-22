//
//  CollectionKitTests.swift
//  CollectionKitTests
//
//  Created by Luke on 3/20/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import XCTest
import CollectionKit

class CollectionKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
      let manager = CollectionLinearVisibleIndexesManager()

      let testData:[ClosedRange<CGFloat>] = [0...100, 0...0.5, 0...0.5]

      var minToIndexes = [(CGFloat, Int)]()
      var maxToIndexes = [(CGFloat, Int)]()
      for (index, data) in testData.enumerated() {
        minToIndexes.append((data.lowerBound, index))
        maxToIndexes.append((data.upperBound, index))
      }

      minToIndexes.sort { left, right in
        return left.0 < right.0
      }

      maxToIndexes.sort { left, right in
        return left.0 < right.0
      }

      manager.reload(minToIndexes: minToIndexes, maxToIndexes: maxToIndexes)
      print(manager.visibleIndexes(min: 20, max: 100))
    }
    
}
