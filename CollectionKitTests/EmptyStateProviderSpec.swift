//
//  EmptyStateProviderSpec.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-11-01.
//  Copyright © 2018 lkzhao. All rights reserved.
//

@testable import CollectionKit
import Quick
import Nimble

class EmptyStateProviderSpec: QuickSpec {

  override func spec() {
    describe("EmptyStateProvider") {
      var collectionView: CollectionView!
      beforeEach {
        collectionView = CollectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
      }

      it("displays empty state view correctly") {
        let dataSource = ArrayDataSource(data: [0, 1, 2, 4])
        let provider = BasicProvider(
          dataSource: dataSource,
          viewSource: { (label: UILabel, data: Int, index: Int) in },
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
        })
        let emptyLabel = UILabel()
        emptyLabel.text = "Empty Label"
        let emptyProvider = EmptyStateProvider(emptyStateView: emptyLabel, content: provider)
        collectionView.provider = emptyProvider
        collectionView.layoutIfNeeded()

        expect(collectionView.visibleCells.count) == 4
        dataSource.data = []
        collectionView.layoutIfNeeded()

        expect(collectionView.visibleCells.count) == 1
        expect((collectionView.subviews[0] as! UILabel).text) == "Empty Label"

        dataSource.data = [1, 2]
        collectionView.layoutIfNeeded()
        expect(collectionView.visibleCells.count) == 2
      }
    }
  }

}

