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

public protocol DecayAnimatable: SolverAnimatable {
    var defaultThreshold: Double { get set }
    var defaultDamping: Double { get set }
}

extension DecayAnimatable {
    public func setDefaultDamping(_ damping: Double) {
        defaultDamping = damping
    }
    public func setDefaultThreshold(_ threshold: Double) {
        defaultThreshold = threshold
    }

    public func decay(initialVelocity: Value? = nil,
                      damping: Double? = nil,
                      threshold: Double? = nil,
                      completionHandler: ((Bool) -> Void)? = nil) {
        if let initialVelocity = initialVelocity {
            velocity.value = initialVelocity
        }
        solver = DecaySolver(damping: damping ?? defaultDamping,
                             threshold: threshold ?? defaultThreshold,
                             current: value, velocity: velocity)
        start(completionHandler)
    }
}
