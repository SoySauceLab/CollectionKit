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

public protocol SpringAnimatable: DecayAnimatable {
    var defaultStiffness: Double { get set }

    var target: AnimationProperty<Value> { get }
}

// convenience
extension SpringAnimatable {
    public func setDefaultStiffness(_ stiffness: Double) {
        defaultStiffness = stiffness
    }

    public func animateTo(_ targetValue: Value,
                          initialVelocity: Value? = nil,
                          stiffness: Double? = nil,
                          damping: Double? = nil,
                          threshold: Double? = nil,
                          completionHandler: ((Bool) -> Void)? = nil) {
        target.value = targetValue
        if let initialVelocity = initialVelocity {
            velocity.value = initialVelocity
        }
        solver = SpringSolver(stiffness: stiffness ?? defaultStiffness,
                              damping: damping ?? defaultDamping,
                              threshold: threshold ?? defaultThreshold,
                              current: value, velocity: velocity, target: target)
        start(completionHandler)
    }
}
