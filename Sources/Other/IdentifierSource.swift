//
//  IdentifierSource.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-09-17.
//

import Foundation

public typealias IdentifierSource<Data> = (Int, Data) -> String

public func defaultIdentifierSource<Data>(at: Int, data: Data) -> String {
  return "\(at)"
}

public func defaultViewIdentifierSource(at: Int, view: UIView) -> String {
  return "\(view.hash)"
}
