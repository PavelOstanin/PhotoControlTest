//
//  AGStrokeSettings.swift
//  AGPhotoEditor
//
//  Created by Pavel on 29.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

open class AGStrokeSettings: NSObject {
    
    /// Color of the brush
    private static let defaultColor = CIColor(color: UIColor.red)
    internal var color: CIColor?
    
    /// Width of the brush
    private static let defaultWidth = CGFloat(5.0)
    internal var width: CGFloat
    
    /// Default initializer
    override public init() {
        color = AGStrokeSettings.defaultColor
        width = AGStrokeSettings.defaultWidth
        super.init()
    }
    
    /// Initializes a StrokeSettings with another StrokeSettings object
    public convenience init(_ settings: AGStrokeSettings) {
        self.init()
        self.color = settings.color
        self.width = settings.width
    }
    
    /// Initializes a StrokeSettings with a color and width
    public convenience init(color: CIColor?, width: CGFloat) {
        self.init()
        self.color = color
        self.width = width
    }
    
    /// Used to decode a StrokeSettings with a decoder
    required public convenience init?(coder aDecoder: NSCoder) {
        let color = aDecoder.decodeObject(forKey: AGStrokeSettings.colorKey) as? CIColor
        var width = aDecoder.decodeObject(forKey: AGStrokeSettings.widthKey) as? CGFloat
        if width == nil {
            width = AGStrokeSettings.defaultWidth
        }
        
        self.init(color: color, width: width!)
    }

}

// MARK: - NSCoding

extension AGStrokeSettings: NSCoding {
    internal static let colorKey = "color"
    internal static let widthKey = "width"
    
    /// Used to encode a StrokeSettings with a coder
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.color, forKey: AGStrokeSettings.colorKey)
        aCoder.encode(self.width, forKey: AGStrokeSettings.widthKey)
    }
}
