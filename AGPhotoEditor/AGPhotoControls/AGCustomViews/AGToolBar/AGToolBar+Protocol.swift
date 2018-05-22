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
    
    func didChangeTextColor(color: UIColor)
    func didChangeTextFont(fontName: String)
    
}

