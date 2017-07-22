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

import UIKit

extension Yaal where Base : UIView {
    public var center: MixAnimation<CGPoint> {
        return animationFor(key: "center",
                            getter: { [weak base] in base?.center },
                            setter: { [weak base] in base?.center = $0 })
    }
    public var alpha: MixAnimation<CGFloat> {
        return animationFor(key: "alpha",
                            getter: { [weak base] in base?.alpha },
                            setter: { [weak base] in base?.alpha = $0 })
    }
    public var bounds: MixAnimation<CGRect> {
        return animationFor(key: "bounds",
                            getter: { [weak base] in base?.bounds },
                            setter: { [weak base] in base?.bounds = $0 })
    }
    public var frame: MixAnimation<CGRect> {
        return animationFor(key: "frame",
                            getter: { [weak base] in base?.frame },
                            setter: { [weak base] in base?.frame = $0 })
    }
    public var backgroundColor: MixAnimation<UIColor> {
        return animationFor(key: "backgroundColor",
                            getter: { [weak base] in base?.backgroundColor },
                            setter: { [weak base] in base?.backgroundColor = $0 })
    }
    public var tintColor: MixAnimation<UIColor> {
        return animationFor(key: "tintColor",
                            getter: { [weak base] in base?.tintColor },
                            setter: { [weak base] in base?.tintColor = $0 })
    }

    public var translation: MixAnimation<CGPoint> { return base.layer.yaal.translation }
    public var translationX: MixAnimation<CGFloat> { return base.layer.yaal.translationX }
    public var translationY: MixAnimation<CGFloat> { return base.layer.yaal.translationY }
    public var translationZ: MixAnimation<CGFloat> { return base.layer.yaal.translationZ }

    public var scale: MixAnimation<CGFloat> { return base.layer.yaal.scale }
    public var scaleX: MixAnimation<CGFloat> { return base.layer.yaal.scaleX }
    public var scaleY: MixAnimation<CGFloat> { return base.layer.yaal.scaleY }

    public var rotation: MixAnimation<CGFloat> { return base.layer.yaal.rotation }
    public var rotationX: MixAnimation<CGFloat> { return base.layer.yaal.rotationX }
    public var rotationY: MixAnimation<CGFloat> { return base.layer.yaal.rotationY }
}
