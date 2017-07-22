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

public class Announcer<Value: VectorConvertible> {
    public typealias Vector = Value.Vector

    public var listeners = [String: (Value, Value) -> Void]()
    public var vectorListeners = [String: (Vector, Vector) -> Void]()

    public var hasListener: Bool {
        return !listeners.isEmpty
    }

    public var hasVectorListener: Bool {
        return !vectorListeners.isEmpty
    }

    public func addListener(_ listener:@escaping (_ old: Value, _ new: Value) -> Void) {
        listeners[UUID().uuidString] = listener
    }
    public func addListenerWith(identifier: String,
                                listener:@escaping (_ old: Value, _ new: Value) -> Void) {
        listeners[identifier] = listener
    }
    public func removeListenerWith(identifier: String) {
        listeners[identifier] = nil
    }
    public func removeAllListeners() {
        listeners.removeAll()
    }

    public func addVectorListener(_ listener:@escaping (_ old: Vector, _ new: Vector) -> Void) {
        vectorListeners[UUID().uuidString] = listener
    }
    public func addVectorListenerWith(identifier: String,
                                      listener:@escaping (_ old: Vector, _ new: Vector) -> Void) {
        vectorListeners[identifier] = listener
    }
    public func removeVectorListenerWith(identifier: String) {
        vectorListeners[identifier] = nil
    }
    public func removeAllVectorListeners() {
        vectorListeners.removeAll()
    }

    public func notify(old: Vector, new: Vector) {
        for listener in vectorListeners.values {
            listener(old, new)
        }
        if !listeners.isEmpty {
            let old = Value.from(vector: old)
            let new = Value.from(vector: new)
            for listener in listeners.values {
                listener(old, new)
            }
        }
    }
}
