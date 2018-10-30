//
//  BasicProviderSpec.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-10-17.
//  Copyright © 2018 lkzhao. All rights reserved.
//

@testable import CollectionKit
import Quick
import Nimble


class BasicProviderSpec: QuickSpec {

  override func spec() {
    describe("BasicProvider") {
      var collectionView: CollectionView!
      beforeEach {
        collectionView = CollectionView()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
      }

      it("support all the initialization methods") {
        collectionView.provider = BasicProvider(
          dataSource: [0, 1, 2, 4],
          viewSource: { (label: UILabel, data: Int, index: Int) in },
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
        })

        collectionView.provider = BasicProvider(
          dataSource: ArrayDataSource(data: [0, 1, 2, 4]),
          viewSource: { (label: UILabel, data: Int, index: Int) in },
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
        })

        collectionView.provider = BasicProvider(
          dataSource: [0, 1, 2, 4],
          viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Int, index: Int) in }),
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
        })

        collectionView.provider = BasicProvider(
          dataSource: [0, 1, 2, 4],
          viewSource: { (label: UILabel, data: Int, index: Int) in },
          sizeSource: ClosureSizeSource(sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          }))

        collectionView.provider = BasicProvider(
          dataSource: ArrayDataSource(data: [0, 1, 2, 4]),
          viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Int, index: Int) in }),
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
        })

        collectionView.provider = BasicProvider(
          dataSource: ArrayDataSource(data: [0, 1, 2, 4]),
          viewSource: { (label: UILabel, data: Int, index: Int) in },
          sizeSource: ClosureSizeSource(sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          }))

        collectionView.provider = BasicProvider(
          dataSource: [0, 1, 2, 4],
          viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Int, index: Int) in }),
          sizeSource: ClosureSizeSource(sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          }))

        collectionView.provider = BasicProvider(
          dataSource: ArrayDataSource(data: [0, 1, 2, 4]),
          viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Int, index: Int) in }),
          sizeSource: ClosureSizeSource(sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          }))

        collectionView.provider = BasicProvider(
          dataSource: [0, 1, 2, 4],
          viewSource: { (label: UILabel, data: Int, index: Int) in }
        )

        collectionView.provider = BasicProvider(
          dataSource: [0, 1, 2, 4],
          viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Int, index: Int) in })
        )

        collectionView.provider = BasicProvider(
          dataSource: ArrayDataSource(data: [0, 1, 2, 4]),
          viewSource: ClosureViewSource(viewUpdater: { (label: UILabel, data: Int, index: Int) in })
        )

        collectionView.provider = BasicProvider(
          dataSource: ArrayDataSource(data: [0, 1, 2, 4]),
          viewSource: { (label: UILabel, data: Int, index: Int) in }
        )
      }
    }
  }

}

