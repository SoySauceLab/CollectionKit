//
//  CollectionSizeProvider.swift
//  CollectionKit
//
//  Created by Luke Zhao on 2017-07-24.
//  Copyright © 2017 lkzhao. All rights reserved.
//

import UIKit

public typealias CollectionSizeProvider<Data> = (Int, Data, CGSize) -> CGSize
