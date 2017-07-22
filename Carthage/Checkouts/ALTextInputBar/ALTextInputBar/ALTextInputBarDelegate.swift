//
//  ALTextInputBarDelegate.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

@objc
public protocol ALTextInputBarDelegate: NSObjectProtocol {
    @objc optional func textViewShouldBeginEditing(textView: ALTextView) -> Bool
    @objc optional func textViewShouldEndEditing(textView: ALTextView) -> Bool
    
    @objc optional func textViewDidBeginEditing(textView: ALTextView)
    @objc optional func textViewDidEndEditing(textView: ALTextView)
    
    @objc optional func textViewDidChange(textView: ALTextView)
    @objc optional func textViewDidChangeSelection(textView: ALTextView)
    
    @objc optional func textView(textView: ALTextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool
    
    @objc optional func inputBarDidChangeHeight(height: CGFloat)
}
