//
//  CollectionComposerSpec.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2017-09-02.
//  Copyright © 2017 lkzhao. All rights reserved.
//

@testable import CollectionKit
import Quick
import Nimble

class CollectionComposerSpec: QuickSpec {

  override func spec() {

    describe("CollectionComposer") {
      it("combines multiple provider") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let composer = CollectionComposer(provider1, provider2, provider3)
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        collectionView.layoutIfNeeded()
        
        expect(collectionView.visibleCells.count) == 8
        expect((collectionView.subviews[0] as! UILabel).text) == "1"
        expect((collectionView.subviews[4] as! UILabel).text) == "a"
        expect((collectionView.subviews[6] as! UILabel).text) == "hello"
      }

      it("supports nesting") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let provider4 = SimpleTestProvider(data: [])
        let provider5 = SimpleTestProvider(data: [5.0])
        let composer = CollectionComposer(
          CollectionComposer(
            CollectionComposer(provider1,
                               provider2),
            provider3),
          CollectionComposer(),
          CollectionComposer(provider4,
                             provider5)
        )
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        collectionView.layoutIfNeeded()

        expect(collectionView.visibleCells.count) == 9
        expect((collectionView.subviews[0] as! UILabel).text) == "1"
        expect((collectionView.subviews[4] as! UILabel).text) == "a"
        expect((collectionView.subviews[6] as! UILabel).text) == "hello"
        expect((collectionView.subviews[8] as! UILabel).text) == "5.0"
      }

      it("triggers reload") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let composer = CollectionComposer(provider1, provider2, provider3)
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1

        composer.sections = [provider2]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 2
        expect(collectionView.visibleCells.count) == 2
        expect((collectionView.subviews[0] as! UILabel).text) == "a"
        expect((collectionView.subviews[1] as! UILabel).text) == "b"

        expect(collectionView.subviews[0].frame.origin) == CGPoint.zero
        composer.layout = RowLayout(justifyContent: .center)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 3
        expect(collectionView.subviews[0].frame.origin) != CGPoint.zero

        composer.presenter = ZoomPresenter()
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 4

        provider2.data = ["b"]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 5
        expect(collectionView.visibleCells.count) == 1
        expect((collectionView.subviews[0] as! UILabel).text) == "b"

        provider1.data = [3, 4, 5] // provider1 is not a section anymore, shouldnt trigger reload
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 5
      }

      it("supports nested update") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let provider4 = SimpleTestProvider(data: [])
        let provider5 = SimpleTestProvider(data: [5.0])
        let composer = CollectionComposer(
          CollectionComposer(
            CollectionComposer(provider1,
                               provider2),
            provider3),
          CollectionComposer(),
          CollectionComposer(provider4,
                             provider5)
        )
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        collectionView.layoutIfNeeded()

        expect(collectionView.visibleCells.count) == 9
        expect((collectionView.subviews[4] as! UILabel).text) == "a"
        provider2.data = ["b", "c", "d"]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 2
        
        expect(collectionView.visibleCells.count) == 10
        expect((collectionView.subviews[4] as! UILabel).text) == "b"
      }

      it("support tap") {
        var lastTappedText: String?
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let tapProvider = CollectionProvider(
          data: [11, 12],
          viewUpdater: { (label: UILabel, data: Int, index: Int) in
            label.text = "\(data)"
          },
          sizeProvider: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          },
          tapHandler: { view, index, dataProvider in
            lastTappedText = view.text
          }
        )
        let composer = CollectionComposer(
          CollectionComposer(provider1,
                             provider2),
          tapProvider
        )
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 200, height: 500)
        collectionView.layoutIfNeeded()
        UITapGestureRecognizer.testLocation = CGPoint(x: 10, y: 110)
        collectionView.tap(gesture: collectionView.tapGestureRecognizer)
        UITapGestureRecognizer.testLocation = nil
        expect(lastTappedText) == "11"
      }
    }
  }

}
