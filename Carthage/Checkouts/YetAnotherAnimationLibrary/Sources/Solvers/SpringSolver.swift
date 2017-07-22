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

public struct SpringSolver<Value: VectorConvertible>: RK4Solver {
    public typealias Vector = Value.Vector
    public let stiffness: Double
    public let damping: Double
    public let threshold: Double
    public let current: AnimationProperty<Value>
    public let velocity: AnimationProperty<Value>
    public let target: AnimationProperty<Value>

    public init(stiffness: Double,
                damping: Double,
                threshold: Double,
                current: AnimationProperty<Value>,
                velocity: AnimationProperty<Value>,
                target: AnimationProperty<Value>) {
        self.stiffness = stiffness
        self.damping = damping
        self.threshold = threshold
        self.current = current
        self.velocity = velocity
        self.target = target
    }

    public func acceleration(current: Vector, velocity: Vector) -> Vector {
        return stiffness * (target.vector - current) - damping * velocity
    }

    public func updateWith(newCurrent: Vector, newVelocity: Vector) -> Bool {
        if newCurrent.distance(between: target.vector) < threshold,
            newVelocity.distance(between: .zero) < threshold {
            current.vector = target.vector
            velocity.vector = .zero
            return true
        } else {
            current.vector = newCurrent
            velocity.vector = newVelocity
            return false
        }
    }
}
