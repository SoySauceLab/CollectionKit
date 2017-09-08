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
        let layout = FlowLayout<CGSize>()
        layout.mockLayout(parentSize: (0, 0))
        expect(layout.frames.count).to(equal(0))
        layout.mockLayout(parentSize: (0, 0), (200, 50))
        expect(layout.frames.count).to(equal(1))
      }

      it("should work with both axis") {
        let layout = FlowLayout<CGSize>()
        layout.mockLayout(parentSize: (100, 100), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (50, 0, 50, 50), (0, 50, 50, 50))))
        layout.axis = .horizontal
        layout.mockLayout(parentSize: (100, 100), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (0, 50, 50, 50), (50, 0, 50, 50))))
      }

      it("should work with both axis with lineSpacing") {
        let layout = FlowLayout<CGSize>(lineSpacing: 10)
        layout.mockLayout(parentSize: (100, 300), (100, 100), (100, 100), (100, 100))
        expect(layout.frames).to(equal(frames((0, 0, 100, 100), (0, 110, 100, 100), (0, 220, 100, 100))))
        layout.axis = .horizontal
        layout.mockLayout(parentSize: (300, 100), (100, 100), (100, 100), (100, 100))
        expect(layout.frames).to(equal(frames((0, 0, 100, 100), (110, 0, 100, 100), (220, 0, 100, 100))))
      }

      it("should work with both axis with minimuminteritemSpacing") {
        let layout = FlowLayout<CGSize>(minimuminteritemSpacing: 10)
        layout.mockLayout(parentSize: (130, 100), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (80, 0, 50, 50), (0, 50, 50, 50))))
        layout.axis = .horizontal
        layout.mockLayout(parentSize: (100, 130), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (0, 80, 50, 50), (50, 0, 50, 50))))
      }

      it("should work with both axis with minimuminteritemSpacing and lineSpacing") {
        let layout = FlowLayout<CGSize>(lineSpacing: 10, minimuminteritemSpacing: 10)
        layout.mockLayout(parentSize: (130, 130), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (80, 0, 50, 50), (0, 80, 50, 50))))
        layout.axis = .horizontal
        layout.mockLayout(parentSize: (130, 130), (50, 50), (50, 50), (50, 50))
        expect(layout.frames).to(equal(frames((0, 0, 50, 50), (0, 80, 50, 50), (80, 0, 50, 50))))
      }
    }
  }
}

