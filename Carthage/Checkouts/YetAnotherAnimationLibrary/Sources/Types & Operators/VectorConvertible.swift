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

public protocol VectorConvertible {
    associatedtype Vector: VectorType
    static func from(vector: Vector) -> Self
    var vector: Vector { get }
}

extension Float: VectorConvertible {
    public typealias Vector = Vector1
    public static func from(vector: Vector1) -> Float {
        return Float(vector)
    }
    public var vector: Vector1 {
        return Vector1(self)
    }
}

extension CGFloat: VectorConvertible {
    public typealias Vector = Vector1
    public static func from(vector: Vector1) -> CGFloat {
        return CGFloat(vector)
    }
    public var vector: Vector1 {
        return Vector1(self)
    }
}

extension CGPoint: VectorConvertible {
    public typealias Vector = Vector2
    public static func from(vector: Vector2) -> CGPoint {
        return CGPoint(x: vector.x, y: vector.y)
    }
    public var vector: Vector2 {
        return [Double(x), Double(y)]
    }
}

extension CGSize: VectorConvertible {
    public typealias Vector = Vector2
    public static func from(vector: Vector2) -> CGSize {
        return CGSize(width: vector.x, height: vector.y)
    }
    public var vector: Vector2 {
        return [Double(width), Double(height)]
    }
}

extension CGRect: VectorConvertible {
    public typealias Vector = Vector4
    public static func from(vector: Vector4) -> CGRect {
        return CGRect(x: vector.x, y: vector.y, width: vector.z, height: vector.w)
    }
    public var vector: Vector4 {
        return [Double(origin.x), Double(origin.y), Double(width), Double(height)]
    }
}

extension UIEdgeInsets: VectorConvertible {
    public typealias Vector = Vector4
    public static func from(vector: Vector4) -> UIEdgeInsets {
        return UIEdgeInsets(top: CGFloat(vector.x), left: CGFloat(vector.y),
                            bottom: CGFloat(vector.z), right: CGFloat(vector.w))
    }
    public var vector: Vector4 {
        return [Double(top), Double(left), Double(bottom), Double(right)]
    }
}

extension CGColor: VectorConvertible {
    private static let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    public typealias Vector = Vector4
    public static func from(vector: Vector4) -> Self {
        let components = [CGFloat(vector.x), CGFloat(vector.y), CGFloat(vector.z), CGFloat(vector.w)]
        let color = self.init(colorSpace: CGColor.rgbColorSpace, components: components)!
        return color
    }

    public var vector: Vector4 {
        var rtn = Vector4()
        if let components = components {
            if 4 == numberOfComponents {
                // RGB colorspace
                rtn[0] = Double(components[0])
                rtn[1] = Double(components[1])
                rtn[2] = Double(components[2])
                rtn[3] = Double(components[3])
            } else if 2 == numberOfComponents {
                // Grey colorspace
                rtn[0] = Double(components[0])
                rtn[1] = Double(components[0])
                rtn[2] = Double(components[0])
                rtn[3] = Double(components[1])
            } else {
                // Use CI to convert
                let ciColor = CIColor(cgColor: self)
                rtn[0] = Double(ciColor.red)
                rtn[1] = Double(ciColor.green)
                rtn[2] = Double(ciColor.blue)
                rtn[3] = Double(ciColor.alpha)
            }
        }
        return rtn
    }
}

extension UIColor: VectorConvertible {
    public typealias Vector = Vector4
    public static func from(vector: Vector4) -> Self {
        return self.init(cgColor: CGColor.from(vector: vector))
    }
    public var vector: Vector4 {
        return cgColor.vector
    }
}
