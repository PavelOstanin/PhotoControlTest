//
//  AGStroke.swift
//  AGPhotoEditor
//
//  Created by Pavel on 29.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

open class AGStroke: NSObject {
    
    /// The points that make up the stroke
    internal var points: [CGPoint]
    
    /// The properties of the stroke
    internal var settings: AGStrokeSettings
    
    /// Default initializer
    override public init() {
        points = []
        settings = AGStrokeSettings()
        super.init()
    }
    
    /// Initialize a stroke with certain points and settings
    public convenience init(points: [CGPoint], settings: AGStrokeSettings) {
        self.init()
        self.points = points
        self.settings = AGStrokeSettings(settings)
    }
    
    /// Used to decode a Stroke with a decoder
    required public convenience init?(coder aDecoder: NSCoder) {
        var points = aDecoder.decodeObject(forKey: AGStroke.pointsKey) as? [CGPoint]
        if points == nil {
            points = []
        }
        
        var settings = aDecoder.decodeObject(forKey: AGStroke.settingsKey) as? AGStrokeSettings
        if settings == nil {
            settings = AGStrokeSettings()
        }
        
        self.init(points: points!, settings: settings!)
    }


}

// MARK: - NSCoding

extension AGStroke: NSCoding {
    internal static let pointsKey = "points"
    internal static let settingsKey = "settings"
    
    /// Used to encode a Stroke with a coder
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.points, forKey: AGStroke.pointsKey)
        aCoder.encode(self.settings, forKey: AGStroke.settingsKey)
    }
}

