//
//  AGCanvasView+Drawing.swift
//  AGPhotoEditor
//
//  Created by Pavel on 22.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

extension AGCanvasView {
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if !isDrawing{
            return
        }
        self.saved = false
        self.pointMoved = false
        self.pointIndex = 0
        self.brush = AGBrush()
        
        let touch = touches.first!
        self.points[0] = touch.location(in: self)
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if !isDrawing{
            return
        }
        let touch = touches.first!
        let currentPoint = touch.location(in: self)
        self.pointMoved = true
        self.pointIndex += 1
        self.points[self.pointIndex] = currentPoint
        
        if self.pointIndex == 4 {
            // move the endpoint to the middle of the line joining the second control point of the first Bezier segment
            // and the first control point of the second Bezier segment
            self.points[3] = CGPoint(x: (self.points[2]!.x + self.points[4]!.x)/2.0, y: (self.points[2]!.y + self.points[4]!.y) / 2.0)
            
            // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
            self.path.move(to: self.points[0]!)
            self.path.addCurve(to: self.points[3]!, controlPoint1: self.points[1]!, controlPoint2: self.points[2]!)
            
            // replace points and get ready to handle the next segment
            self.points[0] = self.points[3]
            self.points[1] = self.points[4]
            self.pointIndex = 1
        }
        
        self.strokePath()

    }
    
    open override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing{
            return
        }
        self.touchesEnded(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing{
            return
        }
        if !self.pointMoved {   // touchesBegan -> touchesEnded : just touched
            self.path.move(to: self.points[0]!)
            self.path.addLine(to: self.points[0]!)
            self.strokePath()
        }
        
        self.mergePaths()      // merge all paths
//        self.didUpdateCanvas()
        
        self.path.removeAllPoints()
        self.pointIndex = 0
    }
    
    fileprivate func strokePath() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.path.lineWidth = (self.brush.width / self.scale)
        self.brush.color.withAlphaComponent(self.brush.alpha).setStroke()
        
        if self.brush.isEraser {
            // should draw on screen for being erased
            self.imageViewForDraw.image?.draw(in: self.bounds)
        }
        
        self.path.stroke(with: brush.blendMode, alpha: 1)
        
        let targetImageView = self.brush.isEraser ? self.imageViewForDraw : self.tempImageView
        targetImageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
    }
    
    fileprivate func mergePaths() {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0)
        
        self.imageViewForDraw.image?.draw(in: self.bounds)
        self.tempImageView.image?.draw(in: self.bounds)
        
        self.imageViewForDraw.image = UIGraphicsGetImageFromCurrentImageContext()
        self.session.append(self.currentDrawing())
        self.tempImageView.image = nil
        
        UIGraphicsEndImageContext()
    }
    
    fileprivate func currentDrawing() -> AGDrawing {
        return AGDrawing(stroke: self.imageViewForDraw.image, background: nil)
    }


}
