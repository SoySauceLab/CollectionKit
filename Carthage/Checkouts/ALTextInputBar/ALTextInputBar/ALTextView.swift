//
//  ALTextView.swift
//  ALTextInputBar
//
//  Created by Alex Littlejohn on 2015/04/24.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

public protocol ALTextViewDelegate: UITextViewDelegate {
    
    /**
    Notifies the receiver of a change to the contentSize of the textView
    
    The receiver is responsible for layout
    
    - parameter textView: The text view that triggered the size change
    - parameter newHeight: The ideal height for the new text view
    */
    func textViewHeightChanged(textView: ALTextView, newHeight: CGFloat)
}

public class ALTextView: UITextView {
    
    override public var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    override public var contentSize: CGSize {
        didSet {
            updateSize()
        }
    }
    
    /// The delegate object to be notified if the content size will change 
    /// The delegate should update handle text view layout
    public weak var textViewDelegate: ALTextViewDelegate? {
        didSet {
            delegate = textViewDelegate
        }
    }
    
    /// The text that appears as a placeholder when the text view is empty
    public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    /// The color of the placeholder text
    public var placeholderColor: UIColor! {
        get {
            return placeholderLabel.textColor
        }
        set(newValue) {
            placeholderLabel.textColor = newValue
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        var _placeholderLabel = UILabel()
        
        _placeholderLabel.clipsToBounds = false
        _placeholderLabel.autoresizesSubviews = false
        _placeholderLabel.numberOfLines = 1
        _placeholderLabel.font = self.font
        _placeholderLabel.backgroundColor = UIColor.clear
        _placeholderLabel.textColor = self.tintColor
        _placeholderLabel.isHidden = true
        
        self.addSubview(_placeholderLabel)
        
        return _placeholderLabel
    }()

    public override var textAlignment: NSTextAlignment {
        get {
            return super.textAlignment
        }
        set {
            super.textAlignment = newValue
            placeholderLabel.textAlignment = newValue
        }
    }

    /// The maximum number of lines that will be shown before the text view will scroll. 0 = no limit
    public var maxNumberOfLines: CGFloat = 0
    public var expectedHeight: CGFloat = 0
    public var minimumHeight: CGFloat {
        get {
            return ceil(font!.lineHeight) + textContainerInset.top + textContainerInset.bottom
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        isScrollEnabled = false
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        placeholderLabel.isHidden = shouldHidePlaceholder()
        if !placeholderLabel.isHidden {
            placeholderLabel.frame = placeholderRectThatFits(rect: bounds)
            sendSubview(toBack: placeholderLabel)
        }
    }
    
    //MARK: - Sizing and scrolling -
    /**
    Notify the delegate of size changes if necessary
    */
    private func updateSize() {
        
        var maxHeight = CGFloat.greatestFiniteMagnitude
        
        if maxNumberOfLines > 0 {
            maxHeight = (ceil(font!.lineHeight) * maxNumberOfLines) + textContainerInset.top + textContainerInset.bottom
        }

        let roundedHeight = roundHeight()
        
        if roundedHeight >= maxHeight {
            expectedHeight = maxHeight
            isScrollEnabled = true
        } else {
            expectedHeight = roundedHeight
            isScrollEnabled = false
        }
        
        if textViewDelegate != nil {
            textViewDelegate?.textViewHeightChanged(textView: self, newHeight:expectedHeight)
        }
        
        ensureCaretDisplaysCorrectly()
    }
    
    /**
    Calculates the correct height for the text currently in the textview as we cannot rely on contentsize to do the right thing
    */
    private func roundHeight() -> CGFloat {
        var newHeight: CGFloat = 0
        
        if let font = font {
            let attributes = [NSFontAttributeName: font]
            let boundingSize = CGSize(width: frame.size.width - textContainerInset.left - textContainerInset.bottom, height: .greatestFiniteMagnitude)
            let size = text.boundingRect(with: boundingSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
            newHeight = ceil(size.height)
        }

        if let font = font, newHeight < font.lineHeight {
            newHeight = font.lineHeight
        }
        
        return newHeight + textContainerInset.top + textContainerInset.bottom
    }
    
    /**
    Ensure that when the text view is resized that the caret displays correctly withing the visible space
    */
    private func ensureCaretDisplaysCorrectly() {
        if let s = selectedTextRange {
            let rect = caretRect(for: s.end)
            UIView.performWithoutAnimation({ () -> Void in
                self.scrollRectToVisible(rect, animated: false)
            })
        }
    }
    
    //MARK: - Placeholder Layout -
    
    /**
    Determines if the placeholder should be hidden dependant on whether it was set and if there is text in the text view
    
    - returns: true if it should not be visible
    */
    private func shouldHidePlaceholder() -> Bool {
        return placeholder.characters.count == 0 || text.characters.count > 0
    }
    
    /**
    Layout the placeholder label to fit in the rect specified
    
    - parameter rect: The constrained size in which to fit the label
    - returns: The placeholder label frame
    */
    private func placeholderRectThatFits(rect: CGRect) -> CGRect {
        let padding = textContainer.lineFragmentPadding
        var placeHolderRect = UIEdgeInsetsInsetRect(rect, textContainerInset)
        placeHolderRect.origin.x += padding
        placeHolderRect.size.width -= padding * 2

        return placeHolderRect
    }

    //MARK: - Notifications -
    
    internal func textViewDidChange() {
        placeholderLabel.isHidden = shouldHidePlaceholder()
        updateSize()
    }
}
