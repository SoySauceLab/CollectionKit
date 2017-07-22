// The MIT License (MIT)
//
// Copyright (c) 2016 Luke Zhao <me@lkzhao.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

fileprivate let minDeltaTime = 1.0 / 30.0

/// The `update(dt:)` function will be called on every screen refresh if started
internal class DisplayLink: NSObject {
    private var displayLink: CADisplayLink?
    private var lastUpdateTime: TimeInterval = 0
    internal var isRunning: Bool {
        return displayLink != nil
    }

    internal func _update() {
        guard let displayLink = displayLink else { return }
        let currentTime = CACurrentMediaTime()
        defer { lastUpdateTime = currentTime }
        var dt = currentTime - lastUpdateTime
        while dt > minDeltaTime {
            update(dt: minDeltaTime)
            dt -= minDeltaTime
        }
        update(dt: dt)
    }

    open func update(dt: TimeInterval) {}

    internal func start() {
        guard !isRunning else { return }
        lastUpdateTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(_update))
        displayLink!.add(to: .main, forMode: .commonModes)
    }

    internal func stop() {
        guard let displayLink = displayLink else { return }
        displayLink.isPaused = true
        displayLink.remove(from: .main, forMode: .commonModes)
        self.displayLink = nil
    }
}
