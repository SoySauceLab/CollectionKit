//
//  YaalCompatible.swift
//  YetAnotherAnimationLibrary
//
//  Created by Anton Siliuk on 21.04.17.
//  Copyright © 2017 Luke Zhao. All rights reserved.
//

import Foundation

public struct Yaal<Base> {
    /// Base object to extend.
    public let base: Base

    /// Creates extensions with base object.
    ///
    /// - parameter base: Base object.
    public init(_ base: Base) {
        self.base = base
    }
}

/// A type that has yaal extensions.
public protocol YaalCompatible {
    /// Extended type
    associatedtype CompatibleType

    /// Yaal extensions.
    static var yaal: Yaal<CompatibleType>.Type { get set }

    /// Yaal extensions.
    var yaal: Yaal<CompatibleType> { get set }
}

extension YaalCompatible {
    /// Yaal extensions.
    public static var yaal: Yaal<Self>.Type {
        get {
            return Yaal<Self>.self
        }
        set {
            // this enables using Yaal to "mutate" base type
        }
    }

    /// Yaal extensions.
    public var yaal: Yaal<Self> {
        get {
            return Yaal(self)
        }
        set {
            // this enables using Yaal to "mutate" base object
        }
    }
}

extension NSObject : YaalCompatible {}
