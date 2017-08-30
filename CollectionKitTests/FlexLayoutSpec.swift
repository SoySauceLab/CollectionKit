//
//  CollectionKitTests.swift
//  CollectionKitTests
//
//  Created by Luke on 3/20/17.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import CollectionKit
import Quick
import Nimble

class FlexLayoutSpec: QuickSpec {

  override func spec() {
    describe("FlexLayout") {
      it("should not crash when parent size is zero") {
        let layout = FlexLayout<CGSize>()
        layout.mockLayout(parentSize: (0, 0))
        expect(layout.frames.count).to(equal(0))
        layout.mockLayout(parentSize: (0, 0), (200, 50))
        expect(layout.frames.count).to(equal(1))
      }

      it("should work with both axis") {
        let layout = FlexLayout<CGSize>()
        layout.mockLayout((200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (0,50,200,50), (0,100,200,50))))
        layout.axis = .horizontal
        layout.mockLayout((200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (200,0,200,50), (400,0,200,50))))
      }

      it("should expand flexed item when there is space") {
        let layout = FlexLayout<CGSize>(flex:["1": FlexValue(flex: 1)])
        layout.mockLayout((200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (0,50,200,200), (0,250,200,50))))

        layout.axis = .horizontal
        layout.mockLayout(parentSize: (700, 50), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (200,0,300,50), (500,0,200,50))))
      }

      it("should shrink flexed item when there is not enough space") {
        let layout = FlexLayout<CGSize>(flex:["1": FlexValue(flex: 1)])
        layout.mockLayout(parentSize: (300, 120), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (0,50,200,20), (0,70,200,50))))

        layout.axis = .horizontal
        layout.mockLayout(parentSize: (300, 300), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (200,0,0,50), (200,0,200,50))))
      }

      it("should expand flexed items according to their flexed value") {
        let layout = FlexLayout<CGSize>(flex:["1": FlexValue(flex: 1, flexBasis: 50), "2": FlexValue(flex: 9, flexBasis: 50)])
        layout.mockLayout(parentSize: (300, 250), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (0,50,200,60), (0,110,200,140))))
        layout.mockLayout(parentSize: (300, 140), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (0,50,200,49), (0,99,200,41))))
      }

      it("should expand flexed items within their range") {
        let layout = FlexLayout<CGSize>(flex:["1": FlexValue(flex: 1, flexBasis: 50, max: 55), "2": FlexValue(flex: 9, flexBasis: 50, min: 45)])
        layout.mockLayout(parentSize: (300, 250), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (0,50,200,55), (0,105,200,145))))
        layout.mockLayout(parentSize: (300, 140), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (0,50,200,45), (0,95,200,45))))

        let layout2 = FlexLayout<CGSize>(flex:["0": FlexValue(flex: 9, flexBasis: 50, min: 44), "1": FlexValue(flex: 1, flexBasis: 50, min: 40), "2": FlexValue(flex: 9, flexBasis: 50, min: 44)])
        layout2.mockLayout(parentSize: (300, 120), (200, 50), (200, 50), (200, 50))
        expect(layout2.frames).to(equal(frames((0,0,200,44), (0,44,200,40), (0,84,200,44))))
        layout2.mockLayout(parentSize: (300, 130), (200, 50), (200, 50), (200, 50))
        expect(layout2.frames).to(equal(frames((0,0,200,44), (0,44,200,42), (0,86,200,44))))
        layout2.mockLayout(parentSize: (300, 150), (200, 50), (200, 50), (200, 50))
        expect(layout2.frames).to(equal(frames((0,0,200,50), (0,50,200,50), (0,100,200,50))))
      }
    }
  }

}
