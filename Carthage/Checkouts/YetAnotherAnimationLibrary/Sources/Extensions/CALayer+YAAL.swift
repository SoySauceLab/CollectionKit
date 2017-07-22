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

extension Yaal where Base : CALayer {
    public var position: MixAnimation<CGPoint> {
        return animationFor(key: "position",
                            getter: { [weak base] in base?.position },
                            setter: { [weak base] in base?.position = $0 })
    }
    public var opacity: MixAnimation<Float> {
        return animationFor(key: "opacity",
                            getter: { [weak base] in base?.opacity },
                            setter: { [weak base] in base?.opacity = $0 })
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
    public var backgroundColor: MixAnimation<CGColor> {
        return animationFor(key: "backgroundColor",
                            getter: { [weak base] in base?.backgroundColor },
                            setter: { [weak base] in base?.backgroundColor = $0 })
    }

    public var cornerRadius: MixAnimation<CGFloat> {
        return animationFor(key: "cornerRadius",
                            getter: { [weak base] in base?.cornerRadius },
                            setter: { [weak base] in base?.cornerRadius = $0 })
    }

    public var zPosition: MixAnimation<CGFloat> {
        return animationFor(key: "zPosition",
                            getter: { [weak base] in base?.zPosition },
                            setter: { [weak base] in base?.zPosition = $0 })
    }

    public var borderWidth: MixAnimation<CGFloat> {
        return animationFor(key: "borderWidth",
                            getter: { [weak base] in base?.borderWidth },
                            setter: { [weak base] in base?.borderWidth = $0 })
    }
    public var borderColor: MixAnimation<CGColor> {
        return animationFor(key: "borderColor",
                            getter: { [weak base] in base?.borderColor },
                            setter: { [weak base] in base?.borderColor = $0 })
    }

    public var shadowRadius: MixAnimation<CGFloat> {
        return animationFor(key: "shadowRadius",
                            getter: { [weak base] in base?.shadowRadius },
                            setter: { [weak base] in base?.shadowRadius = $0 })
    }
    public var shadowColor: MixAnimation<CGColor> {
        return animationFor(key: "shadowColor",
                            getter: { [weak base] in base?.shadowColor },
                            setter: { [weak base] in base?.shadowColor = $0 })
    }
    public var shadowOffset: MixAnimation<CGSize> {
        return animationFor(key: "shadowOffset",
                            getter: { [weak base] in base?.shadowOffset },
                            setter: { [weak base] in base?.shadowOffset = $0 })
    }
    public var shadowOpacity: MixAnimation<Float> {
        return animationFor(key: "shadowOpacity",
                            getter: { [weak base] in base?.shadowOpacity },
                            setter: { [weak base] in base?.shadowOpacity = $0 })
    }

    public var perspective: MixAnimation<CGFloat> {
        return animationFor(key: "perspective",
                            getter: { [weak base] in base?.transform.m34 },
                            setter: { [weak base] in base?.transform.m34 = $0 })
    }

    public var translation: MixAnimation<CGPoint> {
        return animationForKeyPath("transform.translation")
    }
    public var translationX: MixAnimation<CGFloat> {
        return animationForKeyPath("transform.translation.x")
    }
    public var translationY: MixAnimation<CGFloat> {
        return animationForKeyPath("transform.translation.y")
    }
    public var translationZ: MixAnimation<CGFloat> {
        return animationForKeyPath("transform.translation.z")
    }

    public var scale: MixAnimation<CGFloat> { return animationForKeyPath("transform.scale") }
    public var scaleX: MixAnimation<CGFloat> { return animationForKeyPath("transform.scale.x") }
    public var scaleY: MixAnimation<CGFloat> { return animationForKeyPath("transform.scale.y") }

    public var rotation: MixAnimation<CGFloat> { return animationForKeyPath("transform.rotation") }
    public var rotationX: MixAnimation<CGFloat> { return animationForKeyPath("transform.rotation.x") }
    public var rotationY: MixAnimation<CGFloat> { return animationForKeyPath("transform.rotation.y") }
}
