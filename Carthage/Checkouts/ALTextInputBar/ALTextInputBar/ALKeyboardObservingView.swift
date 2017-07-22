//
//  ALKeyboardObservingView.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/05/14.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public let ALKeyboardFrameDidChangeNotification = "ALKeyboardFrameDidChangeNotification"

public class ALKeyboardObservingView: UIView {

    private weak var observedView: UIView?
    private var defaultHeight: CGFloat = 44
    
    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: defaultHeight)
    }


    
    public override func willMove(toSuperview newSuperview: UIView?) {
        
        removeKeyboardObserver()
        if let _newSuperview = newSuperview {
            addKeyboardObserver(newSuperview: _newSuperview)
        }
        
        super.willMove(toSuperview: newSuperview)
    }


    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == superview && keyPath == keyboardHandlingKeyPath() {
            keyboardDidChangeFrame(frame: superview!.frame)
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    public func updateHeight(height: CGFloat) {
        for constraint in constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height && constraint.firstItem as! NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }
    }
    
    private func keyboardHandlingKeyPath() -> String {
        return "center"
    }
    
    private func addKeyboardObserver(newSuperview: UIView) {
        observedView = newSuperview
        newSuperview.addObserver(self, forKeyPath: keyboardHandlingKeyPath(), options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    private func removeKeyboardObserver() {
        if observedView != nil {
            observedView!.removeObserver(self, forKeyPath: keyboardHandlingKeyPath())
            observedView = nil
        }
    }
    
    private func keyboardDidChangeFrame(frame: CGRect) {
        let userInfo: [AnyHashable : Any] = [UIKeyboardFrameEndUserInfoKey: NSValue(cgRect:frame)]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ALKeyboardFrameDidChangeNotification), object: nil, userInfo: userInfo)
    }
    
    deinit {
        removeKeyboardObserver()
    }
}
