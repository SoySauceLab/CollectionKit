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

public struct PipeBuilder<InputValue: VectorConvertible, OutputValue: VectorConvertible> {
    var root: AnimationProperty<InputValue>
    var converter: (InputValue) -> OutputValue?
}

precedencegroup AnimationPipePrecedence {
    associativity: left
    lowerThan: AdditionPrecedence
}
infix operator => : AnimationPipePrecedence

public func =><Value: VectorConvertible>(lhs: AnimationProperty<Value>, rhs: MixAnimation<Value>) {
    lhs.changes.addListener { [weak rhs] _, newValue in
        rhs?.setTo(newValue)
    }
}

public func =><InputValue: VectorConvertible, OutputValue: VectorConvertible>
    (lhs: PipeBuilder<InputValue, OutputValue>, rhs: MixAnimation<OutputValue>) {
    lhs.root.changes.addListener { [weak rhs, converter=lhs.converter] _, newValue in
        if let newValue = converter(newValue) {
            rhs?.setTo(newValue)
        }
    }
}

public func =><InputValue: VectorConvertible, OutputValue: VectorConvertible>
    (lhs: AnimationProperty<InputValue>, rhs:@escaping (InputValue) -> OutputValue?) -> PipeBuilder<InputValue, OutputValue> {
    return PipeBuilder(root: lhs, converter: rhs)
}

public func =><InputValue: VectorConvertible, PipeValue: VectorConvertible, OutputValue: VectorConvertible>
    (lhs: PipeBuilder<InputValue, PipeValue>, rhs:@escaping (PipeValue) -> OutputValue?) -> PipeBuilder<InputValue, OutputValue> {
    return PipeBuilder(root: lhs.root) { [converter=lhs.converter] newValue in
        if let newValue = converter(newValue) {
            return rhs(newValue)
        }
        return nil
    }
}
