//
//  VelocitySmoother.swift
//  Animate
//
//  Created by Luke Zhao on 2017-04-08.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import Foundation

fileprivate let euler = M_E
public struct VelocitySmoother<Value: VectorConvertible>: Solver {
    public let value: AnimationProperty<Value>
    public let velocity: AnimationProperty<Value>
    public let lastValue: AnimationProperty<Value>

    public init(value: AnimationProperty<Value>,
                velocity: AnimationProperty<Value>) {
        self.value = value
        self.velocity = velocity
        lastValue = AnimationProperty<Value>(value: value.value)
    }

    public mutating func solve(dt: TimeInterval) -> Bool {
        let alpha = 1 - pow(euler, -dt / 0.05)
        let currentVelocity = (value.vector - lastValue.vector) / dt
        let smoothed = velocity.vector + alpha * (currentVelocity - velocity.vector)

        lastValue.vector = value.vector
        velocity.vector = smoothed

        if velocity.vector.distance(between: .zero) < alpha {
            velocity.vector = .zero
            return true
        }
        return false
    }
}
