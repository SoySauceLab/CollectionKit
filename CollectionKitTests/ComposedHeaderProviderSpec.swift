//
//  ComposedHeaderProviderSpec.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-10-17.
//  Copyright © 2018 lkzhao. All rights reserved.
//

@testable import CollectionKit
import Quick
import Nimble

class ComposedHeaderProviderSpec: QuickSpec {

  override func spec() {

    describe("ComposedHeaderProvider") {
      let headerViewSource = ClosureViewSource(viewUpdater: { (view: UILabel, data: HeaderData, index) in
        view.text = "header \(data.index)"
      })
      let headerSizeSource = ClosureSizeSource(sizeSource: { (_, data: HeaderData, collectionSize) in
        return CGSize(width: collectionSize.width, height: 50)
      })

      it("support all the initialization methods") {
        let collectionView = CollectionView()
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        collectionView.provider =
          ComposedHeaderProvider(headerViewSource: { (headerView: UILabel, data, index) in },
                                 headerSizeSource: { _, _, collectionSize in return CGSize(width: collectionSize.width, height: 50) },
                                 sections: [provider1, provider2, provider3])
        collectionView.provider =
          ComposedHeaderProvider(headerViewSource: { (headerView: UILabel, data, index) in },
                                 headerSizeSource: headerSizeSource,
                                 sections: [provider1, provider2, provider3])
        collectionView.provider =
          ComposedHeaderProvider(headerViewSource: headerViewSource,
                                 headerSizeSource: { _, _, collectionSize in return CGSize(width: collectionSize.width, height: 50) },
                                 sections: [provider1, provider2, provider3])
        collectionView.provider =
          ComposedHeaderProvider(headerViewSource: headerViewSource,
                                 headerSizeSource: headerSizeSource,
                                 sections: [provider1, provider2, provider3])
      }

      it("combines multiple provider") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let composer = ComposedHeaderProvider(headerViewSource: headerViewSource,
                                              headerSizeSource: headerSizeSource,
                                              sections: [provider1, provider2, provider3])
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        collectionView.layoutIfNeeded()

        expect(collectionView.visibleCells.count) == 11
        expect((collectionView.subviews[1] as! UILabel).text) == "1"
        expect((collectionView.subviews[6] as! UILabel).text) == "a"
        expect((collectionView.subviews[9] as! UILabel).text) == "hello"
      }

      it("supports nesting") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let provider4 = SimpleTestProvider(data: [])
        let provider5 = SimpleTestProvider(data: [5.0])
        let composer = ComposedHeaderProvider(
          headerViewSource: headerViewSource,
          headerSizeSource: headerSizeSource,
          sections: [
            ComposedHeaderProvider(
              headerViewSource: headerViewSource,
              headerSizeSource: headerSizeSource,
              sections: [
                ComposedHeaderProvider(
                  headerViewSource: headerViewSource,
                  headerSizeSource: headerSizeSource,
                  sections: [provider1, provider2]
                ),
                provider3
              ]),
            ComposedProvider(),
            ComposedHeaderProvider(
              headerViewSource: headerViewSource,
              headerSizeSource: headerSizeSource,
              sections: [provider4, provider5]
            )
          ]
        )
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 700)
        collectionView.layoutIfNeeded()

        expect(collectionView.visibleCells.count) == 18
        expect((collectionView.subviews as! [UILabel]).map({ $0.text! })) == [
          "header 0",
            "header 0",
              "header 0",
                "1",
                "2",
                "3",
                "4",
              "header 1",
                "a",
                "b",
            "header 1",
              "hello",
              "collectionKit",
          "header 1",
          "header 2",
            "header 0",
            "header 1",
              "5.0",
        ]
      }

      it("triggers reload") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let composer = ComposedHeaderProvider(
          headerViewSource: headerViewSource,
          headerSizeSource: headerSizeSource,
          sections: [provider1, provider2, provider3]
        )
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1

        composer.sections = [provider2]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 2
        expect(collectionView.visibleCells.count) == 3
        expect((collectionView.subviews[0] as! UILabel).text) == "header 0"
        expect((collectionView.subviews[1] as! UILabel).text) == "a"
        expect((collectionView.subviews[2] as! UILabel).text) == "b"

        composer.animator = ScaleAnimator()
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 3

        provider2.data = ["b"]
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 4
        expect(collectionView.visibleCells.count) == 2
        expect((collectionView.subviews[1] as! UILabel).text) == "b"

        provider1.data = [3, 4, 5] // provider1 is not a section anymore, shouldnt trigger reload
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 4

        expect((collectionView.subviews[0] as! UILabel).frame) == CGRect(x: 0, y: 0, width: 300, height: 50)
        composer.headerSizeSource = ClosureSizeSource(sizeSource: { (index, data, maxSize) -> CGSize in
          return CGSize(width: 50, height: 50)
        })
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 4 // shouldn't trigger reload, but should layout
        expect((collectionView.subviews[0] as! UILabel).frame) == CGRect(x: 0, y: 0, width: 50, height: 50)

        composer.headerViewSource = ClosureViewSource(viewUpdater: { (view, data, index) in })
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 5
      }

      it("shouldn't reload when it doesn't need to") {
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])
        let provider3 = SimpleTestProvider(data: ["hello", "collectionKit"])
        let composer = ComposedHeaderProvider(
          headerViewSource: headerViewSource,
          headerSizeSource: headerSizeSource,
          sections: [provider1, provider2, provider3]
        )
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 300, height: 500)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews[1].frame.origin) == CGPoint(x: 0, y: 50)
        expect(collectionView.subviews[2].frame.origin) == CGPoint(x: 50, y: 50)
        provider1.sizeSource = ClosureSizeSource(sizeSource: { _, _, _ in
          return CGSize(width: 30, height: 30)
        })
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1
        expect(collectionView.subviews[1].frame.origin) == CGPoint(x: 0, y: 50)
        expect(collectionView.subviews[2].frame.origin) == CGPoint(x: 30, y: 50)

        // changing layout shouldn't reload, but will invalidate layout
        provider1.layout = FlowLayout(justifyContent: .spaceBetween)
        collectionView.layoutIfNeeded()
        expect(collectionView.reloadCount) == 1
        expect(collectionView.subviews[1].frame.origin) == CGPoint(x: 0, y: 50)
        expect(collectionView.subviews[2].frame.origin) != CGPoint(x: 30, y: 50)

        // changing layout shouldn't reload, but will invalidate layout
        provider1.layout = FlowLayout()
        composer.layout = FlowLayout(justifyContent: .center)
        collectionView.layoutIfNeeded()
        print(collectionView.subviews.map({ $0.frame }))
        expect(collectionView.reloadCount) == 1
        expect(collectionView.subviews[1].frame.origin) != CGPoint(x: 0, y: 50)
      }

      it("support tap") {
        var lastTappedText: String?
        let provider1 = SimpleTestProvider(data: [1, 2, 3, 4])
        let provider2 = SimpleTestProvider(data: ["a", "b"])

        let tapProvider = BasicProvider(
          dataSource: [11, 12],
          viewSource: {
            (label: UILabel, data: Int, index: Int) in
            label.text = "\(data)"
        },
          sizeSource: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
        },
          tapHandler: { context in
            lastTappedText = context.view.text
        }
        )

        let composer = ComposedHeaderProvider(
          headerViewSource: headerViewSource,
          headerSizeSource: headerSizeSource,
          sections: [
            ComposedHeaderProvider(
              headerViewSource: headerViewSource,
              headerSizeSource: headerSizeSource,
              sections: [provider1,
                         provider2]),
            tapProvider
          ]
        )
        let collectionView = CollectionView(provider: composer)
        collectionView.frame = CGRect(x: 0, y: 0, width: 200, height: 500)
        collectionView.layoutIfNeeded()
        UITapGestureRecognizer.testLocation = CGPoint(x: 10, y: 310)
        collectionView.tap(gesture: collectionView.tapGestureRecognizer)
        UITapGestureRecognizer.testLocation = nil
        expect(lastTappedText) == "11"
      }
    }
  }

}
