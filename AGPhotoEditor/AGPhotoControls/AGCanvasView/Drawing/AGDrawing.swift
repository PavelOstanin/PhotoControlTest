//
//  AGDrawing.swift
//  AGPhotoEditor
//
//  Created by Pavel on 29.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

open class AGDrawing: NSObject {
    
    @objc open var stroke: UIImage?
    @objc open var background: UIImage?
    
    @objc public init(stroke: UIImage? = nil, background: UIImage? = nil) {
        self.stroke = stroke
        self.background = background
    }

}
