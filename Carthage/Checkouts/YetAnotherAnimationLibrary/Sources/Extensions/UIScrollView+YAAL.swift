//
//  UIScrollView+YAAL.swift
//  YetAnotherAnimationLibrary
//
//  Created by Luke on 4/13/17.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import UIKit

extension Yaal where Base : UIScrollView {
    public var contentOffset: MixAnimation<CGPoint> {
        return animationFor(key: "contentOffset",
                            getter: { [weak base] in base?.contentOffset },
                            setter: { [weak base] in base?.contentOffset = $0 })
    }
    public var contentSize: MixAnimation<CGSize> {
        return animationFor(key: "contentSize",
                            getter: { [weak base] in base?.contentSize },
                            setter: { [weak base] in base?.contentSize = $0 })
    }
    public var zoomScale: MixAnimation<CGFloat> {
        return animationFor(key: "zoomScale",
                            getter: { [weak base] in base?.zoomScale },
                            setter: { [weak base] in base?.zoomScale = $0 })
    }
    public var contentInset: MixAnimation<UIEdgeInsets> {
        return animationFor(key: "contentInset",
                            getter: { [weak base] in base?.contentInset },
                            setter: { [weak base] in base?.contentInset = $0 })
    }
    public var scrollIndicatorInsets: MixAnimation<UIEdgeInsets> {
        return animationFor(key: "scrollIndicatorInsets",
                            getter: { [weak base] in base?.scrollIndicatorInsets },
                            setter: { [weak base] in base?.scrollIndicatorInsets = $0 })
    }
}
