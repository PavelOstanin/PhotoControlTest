//
//  AGToolBar+Protocol.swift
//  AGPhotoEditor
//
//  Created by Pavel on 22.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

// MARK: - Control
public enum KeyboardType {
    case keyboard
    case font
    case format
    case color
}


public protocol AGToolBarDelegate {
    
    func didChangeInputView(type: KeyboardType)
    
}


public protocol AGFontInputViewDelegate {
    
    
    func didChangeTextFont(fontName: String)
    
}

public protocol AGColorInputViewDelegate {
    
    func didChangeTextColor(color: UIColor)
    
}

public protocol AGFormatInputViewDelegate {
    
    func didChangeTextAlignment(alignment: NSTextAlignment)
    func didChangeTextSize(size: CGFloat)
    func didChangeTextHeight(height: CGFloat)
    func didChangeTextSpacing(space: CGFloat)
}

