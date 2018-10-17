//
//  WaterfallLayoutSpec.swift
//  CollectionKitTests
//
//  Created by Luke Zhao on 2018-10-17.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import CollectionKit
import Quick
import Nimble

class WaterfallLayoutSpec: QuickSpec {

  override func spec() {
    describe("WaterfallLayout") {
      it("should not crash when parent size is zero") {
        let layout = WaterfallLayout()
        layout.mockLayout(parentSize: (0, 0))
        expect(layout.frames.count).to(equal(0))
        layout.mockLayout(parentSize: (0, 0), (200, 50))
        expect(layout.frames.count).to(equal(1))
      }

      it("should wrap child") {
        let layout = WaterfallLayout()
        layout.mockLayout(parentSize: (100, 100), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (50, 0, 50, 50), (0, 50, 50, 50))))
      }

      it("should work with spacing") {
        let layout = WaterfallLayout(spacing: 10)
        layout.mockLayout(parentSize: (100, 300), (100, 100), (100, 100), (100, 100))
        expect(layout.frames).to(equal(frames((0, 0, 45, 100), (55, 0, 45, 100), (0, 110, 45, 100))))
      }

      it("should work with columns") {
        let layout = WaterfallLayout(columns: 1)
        layout.mockLayout(parentSize: (120, 100), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 120, 50), (0, 50, 120, 50), (0, 100, 120, 50))))
        let layout2 = WaterfallLayout(columns: 3)
        layout2.mockLayout(parentSize: (120, 100), (50, 50), (50, 50), (50, 50))
        expect(layout2.frames).to(equal(frames((0, 0, 40, 50), (40, 0, 40, 50), (80, 0, 40, 50))))
      }

      it("should not display cells outside of the visible area") {
        let layout = WaterfallLayout()
        layout.mockLayout(parentSize: (100, 50), (50, 50), (50, 50), (50, 50), (50, 50))
        let visible = layout.visibleIndexes(visibleFrame: CGRect(x: 0, y: 50, width: 100, height: 50))
        expect(visible).to(equal([2, 3]))
      }
    }
  }
}

