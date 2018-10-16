//
//  CollectionViewSpec.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2017-09-01.
//  Copyright © 2017 lkzhao. All rights reserved.
//

@testable import CollectionKit
import Quick
import Nimble

class CollectionViewSpec: QuickSpec {

  override func spec() {
    describe("CollectionView") {
      var dataSource: ArrayDataSource<Int>!
      var provider: BasicProvider<Int, UILabel>!
      var collectionView: CollectionView!
      beforeEach {
        dataSource = ArrayDataSource(data: [1, 2, 3, 4])
        provider = BasicProvider(
          dataSource: dataSource,
          viewSource: { (label: UILabel, data: Int, index: Int) in
            label.backgroundColor = .red
            label.textAlignment = .center
            label.text = "\(data)"
          },
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          }
        )
        collectionView = CollectionView(provider: provider)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
      }

      it("can display basic provider") {
        expect(collectionView.needsReload) == true
        expect(collectionView.hasReloaded) == false

        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        collectionView.layoutIfNeeded() // triggers reload. In an app, this will be triggered by screen refresh

        expect(collectionView.needsReload) == false
        expect(collectionView.hasReloaded) == true
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 4
        expect(collectionView.subviews[0]).to(beAKindOf(UILabel.self))
        expect(collectionView.subviews[0].backgroundColor) == .red
        expect((collectionView.subviews[0] as! UILabel).text) == "1"
        expect((collectionView.subviews[0] as! UILabel).textAlignment) == NSTextAlignment.center

        expect(provider.layout).to(beAKindOf(FlowLayout.self))
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[2].frame) == CGRect(x: 100, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[3].frame) == CGRect(x: 150, y: 0, width: 50, height: 50)
        expect(collectionView.contentSize) == CGSize(width: 200, height: 50)
      }

      it("only wraps cell to next line") {
        collectionView.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        collectionView.layoutIfNeeded()

        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 4
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[2].frame) == CGRect(x: 0, y: 50, width: 50, height: 50)
        expect(collectionView.subviews[3].frame) == CGRect(x: 50, y: 50, width: 50, height: 50)
        expect(collectionView.contentSize) == CGSize(width: 100, height: 100)
      }

      it("only display cells that are visible") {
        collectionView.frame = CGRect(x: 0, y: 0, width: 100, height: 49)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 2
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 0, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "1"
        expect((collectionView.subviews[1] as! UILabel).text) == "2"
        expect(collectionView.contentSize) == CGSize(width: 100, height: 100)

        collectionView.contentOffset = CGPoint(x: 0, y: 51)
        collectionView.layoutIfNeeded() // trigger load cell. shouldn't trigger reload
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 2
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 50, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 50, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "3"
        expect((collectionView.subviews[1] as! UILabel).text) == "4"
        expect(collectionView.contentSize) == CGSize(width: 100, height: 100)

        collectionView.frame = CGRect(x: 0, y: 0, width: 50, height: 149)
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        collectionView.layoutIfNeeded() // trigger invalidateLayout, load cell. shouldn't trigger reload
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 3
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 0, y: 50, width: 50, height: 50)
        expect(collectionView.subviews[2].frame) == CGRect(x: 0, y: 100, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "1"
        expect((collectionView.subviews[1] as! UILabel).text) == "2"
        expect((collectionView.subviews[2] as! UILabel).text) == "3"
        expect(collectionView.contentSize) == CGSize(width: 50, height: 200)
      }

      it("displays correct cells after reload") {
        collectionView.frame = CGRect(x: 0, y: 0, width: 100, height: 49)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 2
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 0, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "1"
        expect((collectionView.subviews[1] as! UILabel).text) == "2"
        expect(collectionView.contentSize) == CGSize(width: 100, height: 100)

        provider.dataSource = ArrayDataSource(data:[9, 8, 5, 6, 7])
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 2

        expect(collectionView.subviews.count) == 2
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 0, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "9"
        expect((collectionView.subviews[1] as! UILabel).text) == "8"
        expect(collectionView.contentSize) == CGSize(width: 100, height: 150)

        provider.dataSource = ArrayDataSource(data:[8, 5, 6, 7])
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 3

        expect(collectionView.subviews.count) == 2
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 0, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "8"
        expect((collectionView.subviews[1] as! UILabel).text) == "5"
        expect(collectionView.contentSize) == CGSize(width: 100, height: 100)
      }

      it("has correct visible cells") {
        collectionView.frame = CGRect(x: 0, y: 0, width: 100, height: 49)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1

        expect(collectionView.visibleCells.count) == 2
        expect((collectionView.visibleCells[0] as! UILabel).text) == "1"
        expect((collectionView.visibleCells[1] as! UILabel).text) == "2"
      }

      it("has knows correct indexes") {
        collectionView.frame = CGRect(x: 0, y: 0, width: 100, height: 49)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1
        expect(collectionView.visibleCells.count) == 2

        expect(collectionView.indexForCell(at: CGPoint(x: 10, y: 10))) == 0
        expect(collectionView.indexForCell(at: CGPoint(x: 60, y: 10))) == 1
        expect(collectionView.indexForCell(at: CGPoint(x: 10, y: 60))).to(beNil())

        expect((collectionView.cell(at: 0) as! UILabel).text) == "1"
        expect((collectionView.cell(at: 1) as! UILabel).text) == "2"
        expect(collectionView.cell(at: 2)).to(beNil())
        expect(collectionView.cell(at: 3)).to(beNil())
        expect(collectionView.index(for: collectionView.cell(at: 0)!)) == 0
        expect(collectionView.index(for: collectionView.cell(at: 1)!)) == 1
        expect(collectionView.index(for: UIView())).to(beNil())
      }

      it("can handle conflict identifiers") {
        dataSource.identifierMapper = {
          return "\($1)"
        }
        dataSource.data = [0, 0, 0, 0]
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1
        expect(collectionView.visibleCells.count) == 4
        expect(collectionView.subviews.count) == 4

        expect((collectionView.cell(at: 0) as! UILabel).text) == "0"
        expect((collectionView.cell(at: 1) as! UILabel).text) == "0"
        expect((collectionView.cell(at: 2) as! UILabel).text) == "0"
        expect((collectionView.cell(at: 3) as! UILabel).text) == "0"

        dataSource.data = [0, 0, 1, 2]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 2
        expect(collectionView.visibleCells.count) == 4
        expect(collectionView.subviews.count) == 4
        expect((collectionView.cell(at: 0) as! UILabel).text) == "0"
        expect((collectionView.cell(at: 1) as! UILabel).text) == "0"
        expect((collectionView.cell(at: 2) as! UILabel).text) == "1"
        expect((collectionView.cell(at: 3) as! UILabel).text) == "2"

        dataSource.data = [0, 0, 0, 0]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 3
        expect((collectionView.cell(at: 2) as! UILabel).text) == "0"
        expect((collectionView.cell(at: 3) as! UILabel).text) == "0"

        dataSource.data = [1, 2, 3, 4]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 4
        expect(collectionView.visibleCells.count) == 4
        expect(collectionView.subviews.count) == 4
        expect((collectionView.cell(at: 0) as! UILabel).text) == "1"
        expect((collectionView.cell(at: 1) as! UILabel).text) == "2"
        expect((collectionView.cell(at: 2) as! UILabel).text) == "3"
        expect((collectionView.cell(at: 3) as! UILabel).text) == "4"
      }

      it("can switch provider and handle duplicate identifiers") {
        collectionView.frame = CGRect(x: 0, y: 0, width: 100, height: 49)
        collectionView.layoutIfNeeded()

        expect(collectionView.reloadCount) == 1
        expect((collectionView.cell(at: 0) as! UILabel).text) == "1"
        expect((collectionView.cell(at: 1) as! UILabel).text) == "2"

        provider = BasicProvider(
          dataSource: [0, 0, 0, 0],
          viewSource: { (label: UILabel, data: Int, index: Int) in
            label.text = "\(data)"
          },
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          }
        )
        collectionView.provider = provider
        collectionView.layoutIfNeeded()

        expect(collectionView.reloadCount) == 2
        expect((collectionView.cell(at: 0) as! UILabel).text) == "0"
        expect((collectionView.cell(at: 1) as! UILabel).text) == "0"
      }

      it("can shift cells") {
        provider = SimpleTestProvider(data: [0, 1, 2, 3, 4, 5])
        collectionView.provider = provider
        collectionView.frame = CGRect(x: 0, y: 0, width: 500, height: 50)
        collectionView.layoutIfNeeded()

        let cell0 = collectionView.cell(at: 0)
        let cell1 = collectionView.cell(at: 1)

        provider = SimpleTestProvider(data: [5, 4, 3, 2, 1, 0])
        collectionView.provider = provider
        collectionView.layoutIfNeeded()

        expect(collectionView.cell(at: 5)) == cell0
        expect(collectionView.cell(at: 4)) == cell1
      }

      it("handles tap") {
        var lastTappedIndex: Int = -1
        provider = BasicProvider(
          dataSource: [0, 1, 2, 3],
          viewSource: { (label: UILabel, data: Int, index: Int) in
            label.text = "\(data)"
          },
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          },
          tapHandler: { context in
            lastTappedIndex = context.index
          }
        )
        
        collectionView.provider = provider
        collectionView.frame = CGRect(x: 0, y: 0, width: 500, height: 50)
        collectionView.layoutIfNeeded()
        UITapGestureRecognizer.testLocation = CGPoint(x: 10, y: 10)
        collectionView.tap(gesture: collectionView.tapGestureRecognizer)
        UITapGestureRecognizer.testLocation = nil
        expect(lastTappedIndex) == 0
        UITapGestureRecognizer.testLocation = CGPoint(x: 110, y: 10)
        collectionView.tap(gesture: collectionView.tapGestureRecognizer)
        UITapGestureRecognizer.testLocation = nil
        expect(lastTappedIndex) == 2
      }
    }
  }

}
