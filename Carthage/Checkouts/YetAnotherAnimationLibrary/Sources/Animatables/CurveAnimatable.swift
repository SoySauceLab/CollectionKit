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

public protocol CurveAnimatable: SolverAnimatable {
    var defaultCurve: Curve { get set }

    var target: AnimationProperty<Value> { get }
}

extension CurveAnimatable {
    public func setDefaultCurve(_ curve: Curve) {
        defaultCurve = curve
    }

    public func animateTo(_ targetValue: Value,
                          duration: TimeInterval,
                          curve: Curve? = nil,
                          completionHandler: ((Bool) -> Void)? = nil) {
        target.value = targetValue
        solver = CurveSolver(duration: duration,
                             curve: curve ?? defaultCurve,
                             current: value, target: target, velocity: velocity)
        start(completionHandler)
    }
}
