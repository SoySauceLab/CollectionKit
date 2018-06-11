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

class RowLayoutSpec: QuickSpec {

  override func spec() {
    describe("RowLayout") {
      it("should not crash when parent size is zero") {
        let layout = RowLayout()
        layout.mockLayout(parentSize: (0, 0))
        expect(layout.frames.count).to(equal(0))
        layout.mockLayout(parentSize: (0, 0), (200, 50))
        expect(layout.frames.count).to(equal(1))
      }

      it("should work without flex value") {
        let layout = RowLayout()
        layout.mockLayout((200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (200,0,200,50), (400,0,200,50))))
      }

      it("should expand flexed item when there is space") {
        let layout = RowLayout("1")
        layout.mockLayout(parentSize: (700, 50), (200, 50), (200, 50), (200, 50))
        expect(layout.frames).to(equal(frames((0,0,200,50), (200,0, 300, 50), (500,0,200,50))))
      }

      it("should not expand flex item where there is not enough space") {
        let layout = RowLayout("1", "2")
        layout.mockLayout(parentSize: (250, 300), (250, 200), (50, 200), (50, 200))
        expect(layout.frames).to(equal(frames((0,0,250,200), (250,0,50,200), (300,0,50,200))))
      }
    }
  }

}
