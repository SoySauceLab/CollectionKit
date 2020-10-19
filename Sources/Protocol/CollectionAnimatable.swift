//
//  CollectionAnimatable.swift
//  CollectionKit
//
//  Created by Egor Sakhabaev on 19.10.2020.
//

import Foundation
public protocol CollectionAnimatable: class {
    var animator: Animator? {get set}
}
