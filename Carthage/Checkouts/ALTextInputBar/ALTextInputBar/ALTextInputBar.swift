//
//  ALTextInputBar.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/04/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public class ALTextInputBar: UIView, ALTextViewDelegate {
    
    public weak var delegate: ALTextInputBarDelegate?
    public weak var keyboardObserver: ALKeyboardObservingView?
    
    // If true, display a border around the text view
    public var showTextViewBorder = false {
        didSet {
            textViewBorderView.isHidden = !showTextViewBorder
        }
    }
    
    // TextView border insets
    public var textViewBorderPadding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    // TextView corner radius
    public var textViewCornerRadius: CGFloat = 4 {
        didSet {
            textViewBorderView.layer.cornerRadius = textViewCornerRadius
        }
    }
    
    // TextView border width
    public var textViewBorderWidth: CGFloat = 1 {
        didSet {
            textViewBorderView.layer.borderWidth = textViewBorderWidth
        }
    }
    
    // TextView border color
    public var textViewBorderColor = UIColor(white: 0.9, alpha: 1) {
        didSet {
            textViewBorderView.layer.borderColor = textViewBorderColor.cgColor
        }
    }
    
    // TextView background color
    public var textViewBackgroundColor = UIColor.white {
        didSet {
            textViewBorderView.backgroundColor = textViewBackgroundColor
        }
    }
    
    /// Used for the intrinsic content size for autolayout
    public var defaultHeight: CGFloat = 44
    
    /// If true the right button will always be visible else it will only show when there is text in the text view
    public var alwaysShowRightButton = false
    
    /// The horizontal padding between the view edges and its subviews
    public var horizontalPadding: CGFloat = 10
    
    /// The horizontal spacing between subviews
    public var horizontalSpacing: CGFloat = 5
    
    /// Convenience set and retrieve the text view text
    public var text: String! {
        get {
            return textView.text
        }
        set(newValue) {
            textView.text = newValue
            textView.delegate?.textViewDidChange?(textView)
        }
    }
    
    /** 
    This view will be displayed on the left of the text view.
    
    If this view is nil nothing will be displayed, and the text view will fill the space
    */
    public var leftView: UIView? {
        willSet(newValue) {
            if let view = leftView {
                view.removeFromSuperview()
            }
        }
        didSet {
            if let view = leftView {
                addSubview(view)
            }
        }
    }
    
    /**
    This view will be displayed on the right of the text view.
    
    If this view is nil nothing will be displayed, and the text view will fill the space
    If alwaysShowRightButton is false this view will animate in from the right when the text view has content
    */
    public var rightView: UIView? {
        willSet(newValue) {
            if let view = rightView {
                view.removeFromSuperview()
            }
        }
        didSet {
            if let view = rightView {
                addSubview(view)
            }
        }
    }
    
    /// The text view instance
    public let textView: ALTextView = {
        
        let _textView = ALTextView()
        
        _textView.textContainerInset = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)
        _textView.textContainer.lineFragmentPadding = 0
        
        _textView.maxNumberOfLines = defaultNumberOfLines()
        
        _textView.placeholder = "Type here"
        _textView.placeholderColor = UIColor.lightGray
        
        _textView.font = UIFont.systemFont(ofSize: 14)
        _textView.textColor = UIColor.darkGray

        _textView.backgroundColor = UIColor.clear
        
        // This changes the caret color
        _textView.tintColor = UIColor.lightGray
        
        return _textView
    }()
    
    private var showRightButton = false
    private var showLeftButton = false
    
    private var textViewBorderView: UIView!
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        textViewBorderView = createBorderView()
        
        addSubview(textViewBorderView)
        addSubview(textView)
        
        textViewBorderView.isHidden = !showTextViewBorder
        textView.textViewDelegate = self
        
        backgroundColor = UIColor.groupTableViewBackground
    }
    
    private func createBorderView() -> UIView {
        let borderView = UIView()
        
        borderView.backgroundColor = textViewBackgroundColor
        borderView.layer.borderColor = textViewBorderColor.cgColor
        borderView.layer.borderWidth = textViewBorderWidth
        borderView.layer.cornerRadius = textViewCornerRadius
        
        
        return borderView
    }
    
    // MARK: - View positioning and layout -

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: defaultHeight)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let size = frame.size
        let height = floor(size.height)
        
        var leftViewSize = CGSize.zero
        var rightViewSize = CGSize.zero
        
        if let view = leftView {
            leftViewSize = view.bounds.size
            
            let leftViewX: CGFloat = horizontalPadding
            let leftViewVerticalPadding = (defaultHeight - leftViewSize.height) / 2
            let leftViewY: CGFloat = height - (leftViewSize.height + leftViewVerticalPadding)
            
            UIView.performWithoutAnimation {
                view.frame = CGRect(x: leftViewX, y: leftViewY, width: leftViewSize.width, height: leftViewSize.height)
            }
        }

        if let view = rightView {
            rightViewSize = view.bounds.size
            
            let rightViewVerticalPadding = (defaultHeight - rightViewSize.height) / 2
            var rightViewX = size.width
            let rightViewY = height - (rightViewSize.height + rightViewVerticalPadding)
            
            if showRightButton || alwaysShowRightButton {
                rightViewX -= (rightViewSize.width + horizontalPadding)
            }
            
            view.frame = CGRect(x: rightViewX, y: rightViewY, width: rightViewSize.width, height: rightViewSize.height)
        }
        
        let textViewPadding = (defaultHeight - textView.minimumHeight) / 2
        var textViewX = horizontalPadding
        let textViewY = textViewPadding
        let textViewHeight = textView.expectedHeight
        var textViewWidth = size.width - (horizontalPadding + horizontalPadding)
        
        if leftViewSize.width > 0 {
            textViewX += leftViewSize.width + horizontalSpacing
            textViewWidth -= leftViewSize.width + horizontalSpacing
        }
        
        if showTextViewBorder {
            textViewX += textViewBorderPadding.left
            textViewWidth -= textViewBorderPadding.left + textViewBorderPadding.right
        }
        
        if (showRightButton || alwaysShowRightButton) && rightViewSize.width > 0 {
            textViewWidth -= (horizontalSpacing + rightViewSize.width)
        } else {
            
        }
        
        textView.frame = CGRect(x: textViewX, y: textViewY, width: textViewWidth, height: textViewHeight)
        
        let offset = UIEdgeInsetsMake(-textViewBorderPadding.top, -textViewBorderPadding.left, -textViewBorderPadding.bottom, -textViewBorderPadding.right)
        textViewBorderView.frame = UIEdgeInsetsInsetRect(textView.frame, offset)
    }
    
    public func updateViews(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
            
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - ALTextViewDelegate -
    
    public final func textViewHeightChanged(textView: ALTextView, newHeight: CGFloat) {
        
        let padding = defaultHeight - textView.minimumHeight
        let height = padding + newHeight
        
        for constraint in constraints {
            if constraint.firstAttribute == NSLayoutAttribute.height && constraint.firstItem as! NSObject == self {
                constraint.constant = height < defaultHeight ? defaultHeight : height
            }
        }

        frame.size.height = height
        
        if let ko = keyboardObserver {
            ko.updateHeight(height: height)
        }
        
        if let d = delegate, let m = d.inputBarDidChangeHeight {
            m(height)
        }

        textView.frame.size.height = newHeight
    }
    
    public final func textViewDidChange(_ textView: UITextView) {
        
        self.textView.textViewDidChange()

        let shouldShowButton = textView.text.characters.count > 0
        
        if showRightButton != shouldShowButton && !alwaysShowRightButton {
            showRightButton = shouldShowButton
            updateViews(animated: true)
        }

        
        if let d = delegate, let m = d.textViewDidChange {
            m(self.textView)
        }
    }
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        var beginEditing: Bool = true
        if let d = delegate, let m = d.textViewShouldEndEditing {
            beginEditing = m(self.textView)
        }
        return beginEditing
    }
    
    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        var endEditing = true
        if let d = delegate, let m = d.textViewShouldEndEditing {
            endEditing = m(self.textView)
        }
        return endEditing
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if let d = delegate, let m = d.textViewDidBeginEditing {
            m(self.textView)
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if let d = delegate, let m = d.textViewDidEndEditing {
            m(self.textView)
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if let d = delegate, let m = d.textViewDidChangeSelection {
            m(self.textView)
        }
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var shouldChange = true
        if let d = delegate, let m = d.textView {
            shouldChange = m(self.textView, range, text)
        }
        return shouldChange
    }
}
