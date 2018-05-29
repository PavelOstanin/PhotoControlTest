//
//  AGBrush.swift
//  AGPhotoEditor
//
//  Created by Pavel on 29.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

open class AGBrush: NSObject {
    @objc open var color: UIColor = UIColor.black {
        willSet(colorValue) {
            self.color = colorValue
            isEraser = color.isEqual(UIColor.clear)
            blendMode = isEraser ? .clear : .normal
        }
    }
    @objc open var width: CGFloat = 5.0
    @objc open var alpha: CGFloat = 1.0
    
    @objc internal var blendMode: CGBlendMode = .normal
    @objc internal var isEraser: Bool = false
}
