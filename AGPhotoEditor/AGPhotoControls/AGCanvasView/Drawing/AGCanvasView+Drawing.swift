//
//  AGCanvasView+Drawing.swift
//  AGPhotoEditor
//
//  Created by Pavel on 22.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

@objc public protocol AGCanvasDrawViewDelegate {
    /// triggered when undo is enabled (only if it was previously disabled)
    @objc optional func undoEnabled()
    
    /// triggered when undo is disabled (only if it previously enabled)
    @objc optional func undoDisabled()
    
    /// triggered when redo is enabled (only if it was previously disabled)
    @objc optional func redoEnabled()
    
    /// triggered when redo is disabled (only if it previously enabled)
    @objc optional func redoDisabled()
    
    /// triggered when clear is enabled (only if it was previously disabled)
    @objc optional func clearEnabled()
    
    /// triggered when clear is disabled (only if it previously enabled)
    @objc optional func clearDisabled()
}


extension AGCanvasView {
    
    override public func touchesBegan(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if !isDrawing{
            return
        }
        pointIndex = 0;
        if let touch = touches.first {
            let stroke = AGStroke(points: [touch.location(in: self)],
                                  settings: settings)
            stack.append(stroke)
            self.points[0] = touch.location(in: self)
        }
        
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if !isDrawing{
            return
        }
        if let touch = touches.first {
            let stroke = stack.last!
            let lastPoint = stroke.points.last
            let currentPoint = touch.location(in: self)
            drawLineWithContext(fromPoint: lastPoint!, toPoint: currentPoint, properties: stroke.settings)
            stroke.points.append(currentPoint)
        }
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing{
            return
        }
        let stroke = stack.last!
        if stroke.points.count == 1 {
            let lastPoint = stroke.points.last!
            drawLineWithContext(fromPoint: lastPoint, toPoint: lastPoint, properties: stroke.settings)
        }
        
        self.path.removeAllPoints()
        self.pointIndex = 0
        
        if !drawUndoManager.canUndo {
            delegate?.undoEnabled?()
        }
        
        if drawUndoManager.canRedo {
            delegate?.redoDisabled?()
        }
        
        if stack.count == 1 {
            delegate?.clearEnabled?()
        }
        
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(popDrawing), object: nil)
    }
    
    /// If possible, it will redo the last undone stroke
    open func redo() {
        if drawUndoManager.canRedo {
            let stackCount = stack.count
            
            if !drawUndoManager.canUndo {
                delegate?.undoEnabled?()
            }
            
            drawUndoManager.redo()
            
            if !drawUndoManager.canRedo {
                self.delegate?.redoDisabled?()
            }
            
            updateClear(oldStackCount: stackCount)
        }
    }
    
    /// If possible, it will undo the last stroke
    open func undo() {
        if drawUndoManager.canUndo {
            let stackCount = stack.count
            
            if !drawUndoManager.canRedo {
                delegate?.redoEnabled?()
            }
            
            drawUndoManager.undo()
            
            if !drawUndoManager.canUndo {
                delegate?.undoDisabled?()
            }
            
            updateClear(oldStackCount: stackCount)
        }
    }
    
    internal func updateClear(oldStackCount: Int) {
        if oldStackCount > 0 && stack.count == 0 {
            delegate?.clearDisabled?()
        } else if oldStackCount == 0 && stack.count > 0 {
            delegate?.clearEnabled?()
        }
    }
    
    /// Removes the last Stroke from stack
    @objc internal func popDrawing() {
        drawUndoManager.registerUndo(withTarget: self,
                                          selector: #selector(pushDrawing(_:)),
                                          object: stack.popLast())
        redrawStack()
    }
    
    /// Adds a new stroke to the stack
    @objc internal func pushDrawing(_ stroke: AGStroke) {
        stack.append(stroke)
        drawStrokeWithContext(stroke)
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(popDrawing), object: nil)
    }
    
    /// Draws all of the strokes
    @objc internal func pushAll(_ strokes: [AGStroke]) {
        stack = strokes
        redrawStack()
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(clearDrawing), object: nil)
    }
    
    @objc open func clearDrawing() {
        if !drawUndoManager.canUndo {
            delegate?.undoEnabled?()
        }
        
        if drawUndoManager.canRedo {
            delegate?.redoDisabled?()
        }
        
        if stack.count > 0 {
            delegate?.clearDisabled?()
        }
        
        drawUndoManager.registerUndo(withTarget: self, selector: #selector(pushAll(_:)), object: stack)
        stack = []
        redrawStack()
    }


}

// MARK: - Drawing

fileprivate extension AGCanvasView {
    
    /// Begins the image context
    func beginImageContext() {
        UIGraphicsBeginImageContextWithOptions(self.imageViewForDraw.frame.size, false, UIScreen.main.scale)
    }
    
    /// Ends image context and sets UIImage to what was on the context
    func endImageContext() {
        imageViewForDraw.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    /// Draws the current image for context
    func drawCurrentImage() {
        imageViewForDraw.image?.draw(in: imageViewForDraw.bounds)
    }
    
    /// Clears view, then draws stack
    func redrawStack() {
        beginImageContext()
        for stroke in stack {
            drawStroke(stroke)
        }
        endImageContext()
    }
    
    /// Draws a single Stroke
    func drawStroke(_ stroke: AGStroke) {
        let properties = stroke.settings
        let points = stroke.points
        
        if points.count == 1 {
            let point = points[0]
            drawLine(fromPoint: point, toPoint: point, properties: properties)
        }
        
        for i in stride(from: 1, to: points.count, by: 1) {
            let point0 = points[i - 1]
            let point1 = points[i]
            drawLine(fromPoint: point0, toPoint: point1, properties: properties)
        }
    }
    
    /// Draws a single Stroke (begins/ends context
    func drawStrokeWithContext(_ stroke: AGStroke) {
        beginImageContext()
        drawCurrentImage()
        drawStroke(stroke)
        endImageContext()
    }
    
    /// Draws a line between two points
    func drawLine(fromPoint: CGPoint, toPoint: CGPoint, properties: AGStrokeSettings) {
        let context = UIGraphicsGetCurrentContext()
        
//        self.pointIndex+=1
//        self.points[self.pointIndex] = toPoint
//        if self.pointIndex == 4 {
//            // move the endpoint to the middle of the line joining the second control point of the first Bezier segment
//            // and the first control point of the second Bezier segment
//            self.points[3] = CGPoint(x: (self.points[2]!.x + self.points[4]!.x)/2.0, y: (self.points[2]!.y + self.points[4]!.y) / 2.0)
//
//            // add a cubic Bezier from pt[0] to pt[3], with control points pt[1] and pt[2]
//            context!.move(to: self.points[0]!)
//            context!.addCurve(to: self.points[3]!, control1: self.points[1]!, control2: self.points[2]!)
//
//            // replace points and get ready to handle the next segment
//            self.points[0] = self.points[3]
//            self.points[1] = self.points[4]
//            self.pointIndex = 1
//        }
//        else{
            context!.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
            context!.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
//        }
        
        
        
        
        context!.setLineCap(CGLineCap.round)
        context!.setLineWidth(properties.width)
        let color = properties.color
        if color != nil {
            context!.setStrokeColor(red: properties.color!.red,
                                    green: properties.color!.green,
                                    blue: properties.color!.blue,
                                    alpha: properties.color!.alpha)
            context!.setBlendMode(CGBlendMode.normal)
        } else {
            context!.setBlendMode(CGBlendMode.clear)
        }
        
        context!.strokePath()
        
        
    }
    
    /// Draws a line between two points (begins/ends context)
    func drawLineWithContext(fromPoint: CGPoint, toPoint: CGPoint, properties: AGStrokeSettings) {
        beginImageContext()
        drawCurrentImage()
        drawLine(fromPoint: fromPoint, toPoint: toPoint, properties: properties)
        endImageContext()
    }
}
