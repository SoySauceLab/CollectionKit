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

public protocol RK4Solver: Solver {
    associatedtype Value: VectorConvertible
    typealias Vector = Value.Vector

    mutating func solve(dt: TimeInterval) -> Bool

    var current: AnimationProperty<Value> { get }
    var velocity: AnimationProperty<Value> { get }
    func acceleration(current: Vector, velocity: Vector) -> Vector
    func updateWith(newCurrent: Vector, newVelocity: Vector) -> Bool
}

extension RK4Solver {
    // http://gafferongames.com/game-physics/integration-basics/
    public func solve(dt: TimeInterval) -> Bool {
        var dx = Vector.zero
        var dv = Vector.zero
        evalutate(dt: 0, dx: &dx, dv: &dv)
        var dxdt = dx
        var dvdt = dv
        evalutate(dt: 0.5 * dt, dx: &dx, dv: &dv)
        dxdt = dxdt + 2 * dx
        dvdt = dvdt + 2 * dv
        evalutate(dt: 0.5 * dt, dx: &dx, dv: &dv)
        dxdt = dxdt + 2 * dx
        dvdt = dvdt + 2 * dv
        evalutate(dt: dt, dx: &dx, dv: &dv)
        dxdt = dxdt + dx
        dvdt = dvdt + dv

        let newCurrent = current.vector + dxdt * (dt / 6.0)
        let newVelocity = velocity.vector + dvdt * (dt / 6.0)
        return updateWith(newCurrent: newCurrent, newVelocity: newVelocity)
    }

    func evalutate(dt: TimeInterval, dx: inout Vector, dv: inout Vector) {
        let x = current.vector + dx * dt
        let v = velocity.vector + dv * dt
        let a = acceleration(current: x, velocity: v)
        dx = v
        dv = a
    }
}
