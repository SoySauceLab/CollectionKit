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

import Foundation

public struct CurveSolver<Value: VectorConvertible>: Solver {
    public let current: AnimationProperty<Value>
    public let target: AnimationProperty<Value>
    public let velocity: AnimationProperty<Value>
    public let curve: Curve
    public let duration: TimeInterval
    public var start: Value.Vector

    public var time: TimeInterval = 0

    init(duration: TimeInterval, curve: Curve,
         current: AnimationProperty<Value>,
         target: AnimationProperty<Value>,
         velocity: AnimationProperty<Value>) {
        self.current = current
        self.target = target
        self.velocity = velocity
        self.duration = duration
        self.curve = curve
        self.start = current.vector
    }

    public mutating func solve(dt: TimeInterval) -> Bool {
        time += dt
        if time > duration {
            current.vector = target.vector
            velocity.vector = .zero
            return true
        }
        let t = curve.solve(time / duration)
        let oldCurrent = current.vector
        current.vector = (target.vector - start) * t + start
        velocity.vector = (current.vector - oldCurrent) / dt
        return false
    }
}
