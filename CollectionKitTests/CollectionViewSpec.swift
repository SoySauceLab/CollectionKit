//
//  CollectionViewSpec.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2017-09-01.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import CollectionKit
import Quick
import Nimble

class CollectionViewSpec: QuickSpec {

  override func spec() {
    describe("CollectionView") {
      var provider: CollectionProvider<Int, UILabel>!
      var collectionView: CollectionView!
      beforeEach {
        provider = CollectionProvider(
          data: [1, 2, 3, 4],
          viewUpdater: { (label: UILabel, index: Int, data: Int) in
            label.backgroundColor = .red
            label.layer.cornerRadius = 8
            label.textAlignment = .center
            label.text = "\(data)"
          },
          sizeProvider: { (index: Int, data: Int, collectionSize: CGSize) -> CGSize in
            return CGSize(width: 50, height: 50)
          }
        )
        collectionView = CollectionView()
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.provider = provider
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
        expect((collectionView.subviews[0] as! UILabel).text) == "0"
        expect((collectionView.subviews[0] as! UILabel).textAlignment) == NSTextAlignment.center

        expect(provider.layout).to(beAKindOf(FlowLayout<Int>.self))
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
        expect((collectionView.subviews[0] as! UILabel).text) == "0"
        expect((collectionView.subviews[1] as! UILabel).text) == "1"
        expect(collectionView.contentSize) == CGSize(width: 100, height: 100)

        collectionView.contentOffset = CGPoint(x: 0, y: 51)
        collectionView.layoutIfNeeded() // trigger load cell. shouldn't trigger reload
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 2
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 50, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 50, y: 50, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "2"
        expect((collectionView.subviews[1] as! UILabel).text) == "3"
        expect(collectionView.contentSize) == CGSize(width: 100, height: 100)

        collectionView.frame = CGRect(x: 0, y: 0, width: 50, height: 149)
        collectionView.contentOffset = CGPoint(x: 0, y: 0)
        collectionView.layoutIfNeeded() // trigger invalidateLayout, load cell. shouldn't trigger reload
        expect(collectionView.reloadCount) == 1

        expect(collectionView.subviews.count) == 3
        expect(collectionView.subviews[0].frame) == CGRect(x: 0, y: 0, width: 50, height: 50)
        expect(collectionView.subviews[1].frame) == CGRect(x: 0, y: 50, width: 50, height: 50)
        expect(collectionView.subviews[2].frame) == CGRect(x: 0, y: 100, width: 50, height: 50)
        expect((collectionView.subviews[0] as! UILabel).text) == "0"
        expect((collectionView.subviews[1] as! UILabel).text) == "1"
        expect((collectionView.subviews[2] as! UILabel).text) == "2"
        expect(collectionView.contentSize) == CGSize(width: 50, height: 200)
      }
    }
  }

}
