//
//  AGTextView+Attributed.swift
//  AGPhotoEditor
//
//  Created by Pavel on 24.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

extension UITextView {
    
    func getCurrentTextAttributes() -> [NSAttributedStringKey : Any]{
        let style = getCurrentTextParagraphStyle()
        var space: CGFloat = 0
        if (self.attributedText.string.count != 0){
            if let spaceTemp = self.attributedText.attributes(at: 0, effectiveRange: nil)[NSAttributedStringKey.kern] {
                space = spaceTemp as! CGFloat
            }
        }
        var font = UIFont.init(name: constTextFontName, size: constTextFontSize)
        if (self.attributedText.string.count != 0){
            if let fontTemp = self.attributedText.attributes(at: 0, effectiveRange: nil)[NSAttributedStringKey.font] {
                font = fontTemp as? UIFont
            }
        }
        if let color = self.textColor{
            return [NSAttributedStringKey.kern : space, NSAttributedStringKey.paragraphStyle : style, NSAttributedStringKey.foregroundColor : color, NSAttributedStringKey.font : font as Any] as [NSAttributedStringKey : Any]
        }
        return [:]
    }
    
    func getCurrentTextParagraphStyle() -> NSMutableParagraphStyle{
        var style = NSMutableParagraphStyle()
        if (self.attributedText.string.count != 0){
            if let styleTemp = self.attributedText.attributes(at: 0, effectiveRange: nil)[NSAttributedStringKey.paragraphStyle] {
                style = styleTemp as! NSMutableParagraphStyle
            }
        }
        return style
    }
    
}
