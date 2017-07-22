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

open class ValueAnimation<Value: VectorConvertible>: Animation {
    typealias Vector = Value.Vector

    // getter returns optional because we dont want strong references inside the getter block
    public var getter: () -> Value?
    public var setter: (Value) -> Void

    public let value: AnimationProperty<Value>

    open override func willStart() {
        super.willStart()
        updateWithCurrentState()
    }

    open override func didUpdate() {
        super.didUpdate()
        setter(value.value)
    }

    public init(getter:@escaping () -> Value?, setter:@escaping (Value) -> Void) {
        self.value = AnimationProperty<Value>()
        self.getter = getter
        self.setter = setter
    }

    public init(value: AnimationProperty<Value>) {
        self.value = value
        self.getter = { return nil }
        self.setter = { newValue in }
    }

    public func setTo(_ value: Value) {
        self.value.value = value
        setter(value)
    }

    public func updateWithCurrentState() {
        if let currentValue = getter() {
            value.value = currentValue
        }
    }

    public func from(_ value: Value) -> Self {
        self.value.value = value
        setter(value)
        return self
    }
}
