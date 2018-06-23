//
//  SectionProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2018-06-13.
//  Copyright © 2018 lkzhao. All rights reserved.
//

import Foundation

public protocol SectionProvider: Provider {
  func section(at: Int) -> Provider?
}

extension SectionProvider {
  public func flattenedProvider() -> ItemProvider {
    return FlattenedProvider(provider: self)
  }
}
