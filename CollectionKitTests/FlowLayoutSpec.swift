//
//  FlowLayoutSpec.swift
//  CollectionKit
//
//  Created by yansong li on 2017-09-04.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import CollectionKit
import Quick
import Nimble

class FlowLayoutSpec: QuickSpec {

  override func spec() {
    describe("FlowLayout") {
      it("should not crash when parent size is zero") {
        let layout = FlowLayout()
        layout.mockLayout(parentSize: (0, 0))
        expect(layout.frames.count).to(equal(0))
        layout.mockLayout(parentSize: (0, 0), (200, 50))
        expect(layout.frames.count).to(equal(1))
      }

      it("should wrap child") {
        let layout = FlowLayout()
        layout.mockLayout(parentSize: (100, 100), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (50, 0, 50, 50), (0, 50, 50, 50))))
      }

      it("should work with linespacing") {
        let layout = FlowLayout(lineSpacing: 10)
        layout.mockLayout(parentSize: (100, 300), (100, 100), (100, 100), (100, 100))
        expect(layout.frames).to(equal(frames((0, 0, 100, 100), (0, 110, 100, 100), (0, 220, 100, 100))))
      }

      it("should work with interitemspacing") {
        let layout = FlowLayout(interitemSpacing: 10)
        layout.mockLayout(parentSize: (130, 100), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (60, 0, 50, 50), (0, 50, 50, 50))))
      }

      it("should work with interitemspacing and linespacing") {
        let layout = FlowLayout(lineSpacing: 10, interitemSpacing: 10)
        layout.mockLayout(parentSize: (130, 130), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (60, 0, 50, 50), (0, 60, 50, 50))))
      }

      it("should not display cells outside of the visible area") {
        let layout = FlowLayout().transposed()
        layout.mockLayout(parentSize: (100, 50), (50, 50), (50, 50), (50, 50), (50, 50))
        let visible = layout.visibleIndexes(visibleFrame: CGRect(x: 50, y: 0, width: 100, height: 50))
        expect(visible).to(equal([1, 2]))
      }
    }
  }
}

