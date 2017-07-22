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

extension NSObject {
    internal class YaalState {
        internal init() {}
        internal var animations: [String: Any] = [:]
    }

    internal var yaalState: YaalState {
        struct AssociatedKeys {
            internal static var yaalState = "yaalState"
        }
        if let state = objc_getAssociatedObject(self, &AssociatedKeys.yaalState) as? YaalState {
            return state
        } else {
            let state = YaalState()
            objc_setAssociatedObject(self, &AssociatedKeys.yaalState, state, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return state
        }
    }
}

extension Yaal where Base : NSObject {
    public func animationFor<Value: VectorConvertible>(key: String,
                             getter: @escaping () -> Value?,
                             setter: @escaping (Value) -> Void) -> MixAnimation<Value> {
        if let anim = base.yaalState.animations[key] as? MixAnimation<Value> {
            return anim
        } else {
            let anim = MixAnimation(getter: getter, setter: setter)
            base.yaalState.animations[key] = anim
            return anim
        }
    }

    @discardableResult public func register<Value: VectorConvertible>(key: String,
                                            getter: @escaping () -> Value?,
                                            setter: @escaping (Value) -> Void) -> MixAnimation<Value> {
        return animationFor(key: key, getter: getter, setter: setter)
    }

    public func animationFor<Value: VectorConvertible>(key: String) -> MixAnimation<Value>? {
        return base.yaalState.animations[key] as? MixAnimation<Value>
    }

    public func animationForKeyPath<Value: VectorConvertible>(_ keyPath: String) -> MixAnimation<Value> {
        return animationFor(key:keyPath,
                            getter: { [weak base] in base?.value(forKeyPath:keyPath) as? Value },
                            setter: { [weak base] in base?.setValue($0, forKeyPath:keyPath) })
    }
}
