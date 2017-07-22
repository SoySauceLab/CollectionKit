//
//  ALTextInputUtilities.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

internal func defaultNumberOfLines() -> CGFloat {
    if UIDevice.isIPad {
        return 8;
    }
    if UIDevice.isIPhone4 {
        return 4;
    }
    
    return 6;
}

internal extension UIDevice {
    internal static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    internal static var isIPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    internal static var isIPhone4: Bool {
        return UIDevice.isIPhone && UIScreen.main.bounds.size.height < 568.0
    }
}
