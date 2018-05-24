//
//  AGCanvasView+InputView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 24.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

extension AGCanvasView: AGFontInputViewDelegate {
    
    func didChangeTextFont(fontName: String) {
        activeTextView?.font = UIFont.init(name: fontName, size: (activeTextView?.font?.pointSize)!)
    }
    
}

extension AGCanvasView: AGColorInputViewDelegate {
    
    func didChangeTextColor(color: UIColor) {
        activeTextView?.textColor = color
    }
    
}

extension AGCanvasView: AGFormatInputViewDelegate {
    
    func didChangeTextAlignment(alignment: NSTextAlignment) {
        activeTextView?.textAlignment = alignment
    }
    
    func didChangeTextSize(size: CGFloat) {
        var attributes = activeTextView?.getCurrentTextAttributes()
        attributes![NSAttributedStringKey.font] = UIFont.init(name: (activeTextView?.font?.fontName)!, size: size)
        activeTextView?.attributedText = NSAttributedString(string: activeTextView?.text ?? "", attributes: attributes)
        self.textViewDidChange(activeTextView!)
    }
    
    func didChangeTextHeight(height: CGFloat) {
        var attributes = activeTextView?.getCurrentTextAttributes()
        let style = activeTextView?.getCurrentTextParagraphStyle()
        style?.lineSpacing = height
        attributes![NSAttributedStringKey.paragraphStyle] = style
        activeTextView?.attributedText = NSAttributedString(string: activeTextView?.text ?? "", attributes: attributes)
        self.textViewDidChange(activeTextView!)
    }
    
    func didChangeTextSpacing(space: CGFloat) {
        var attributes = activeTextView?.getCurrentTextAttributes()
        attributes![NSAttributedStringKey.kern] = space
        activeTextView?.attributedText = NSAttributedString(string: activeTextView?.text ?? "", attributes: attributes)
        self.textViewDidChange(activeTextView!)
    }

}
