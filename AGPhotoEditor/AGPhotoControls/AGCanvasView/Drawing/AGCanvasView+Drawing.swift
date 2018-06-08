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
    
    // Handles the start of a touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing{
            return
        }
        
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        firstTouch = true
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        let stroke = AGStroke(points: [location],
                              settings: settings)
        stack.append(stroke)
    }
    
    // Handles the continuation of a touch.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing{
            return
        }
        
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        
        // Convert touch point from UIView referential to OpenGL one (upside-down flip)
        //        if firstTouch {
        //            firstTouch = false
        //            previousLocation = touch.previousLocation(in: self)
        //            previousLocation.y = bounds.size.height - previousLocation.y
        //        } else {
        location = touch.location(in: self)
        location.y = bounds.size.height - location.y
        previousLocation = touch.previousLocation(in: self)
        previousLocation.y = bounds.size.height - previousLocation.y
        //        }
        
        // Render the stroke
        let stroke = stack.last!
        stroke.points.append(location)
        self.renderLine(from: previousLocation, to: location, stroke: stroke)
        
    }
    
    // Handles the end of a touch event when the touch is a tap.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing{
            return
        }
        let bounds = self.bounds
        let touch = event!.touches(for: self)!.first!
        if firstTouch {
            firstTouch = false
            previousLocation = touch.previousLocation(in: self)
            previousLocation.y = bounds.size.height - previousLocation.y
            let stroke = stack.last!
            stroke.points.append(location)
            self.renderLine(from: previousLocation, to: location, stroke: stroke)
        }
        
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
    
    // Handles the end of a touch event.
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isDrawing{
            return
        }
        // If appropriate, add code necessary to save the state of the application.
        // This application is not saving state.
    }


    /// If possible, it will redo the last undone stroke
    open func redo() {
//        self.erase()
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
        self.erase()
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
        drawStroke(stroke)
        // Display the buffer
        glBindRenderbuffer(GL_RENDERBUFFER.ui, viewRenderbuffer)
        context.presentRenderbuffer(GL_RENDERBUFFER.l)
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
        self.erase()
    }


}

// MARK: - Drawing

fileprivate extension AGCanvasView {

    
    /// Clears view, then draws stack
    func redrawStack() {
        for stroke in stack {
            drawStroke(stroke)
        }
        // Display the buffer
        glBindRenderbuffer(GL_RENDERBUFFER.ui, viewRenderbuffer)
        context.presentRenderbuffer(GL_RENDERBUFFER.l)
    }
    
    /// Draws a single Stroke
    func drawStroke(_ stroke: AGStroke) {
        let properties = stroke.settings
        glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], GLfloat(properties.width))
        setBrushColor(red: (properties.color?.red)!, green: (properties.color?.green)!, blue: (properties.color?.blue)!)
        var points = stroke.points
        if  points.count == 1{
            points.append(points.first!)
        }
        struct Static {
            static var vertexBuffer: [GLfloat] = []
        }
        var count = 0
        var totalCount = 0
        var tempArray : [CGFloat] = []
        EAGLContext.setCurrent(context)
        glBindFramebuffer(GL_FRAMEBUFFER.ui, viewFramebuffer)
        for i in stride(from: 1, to: points.count, by: 1) {
            let point0 = points[i - 1]
            let point1 = points[i]
            
            // Convert locations from Points to Pixels
            let scale = self.contentScaleFactor
            var start = point0
            start.x *= scale
            start.y *= scale
            var end = point1
            end.x *= scale
            end.y *= scale
            
            // Add points to the buffer so there are drawing points every X pixels
            count = max(Int(ceilf(sqrtf((end.x - start.x).f * (end.x - start.x).f + (end.y - start.y).f * (end.y - start.y).f) / kBrushPixelStep.f)), 1)
            totalCount = totalCount + count
            for i in 0..<count {
                tempArray.append(CGFloat(start.x.f + (end.x - start.x).f * (i.f / count.f)))
                tempArray.append(CGFloat(start.y.f + (end.y - start.y).f * (i.f / count.f)))
            }
        }
        // Allocate vertex array buffer
        Static.vertexBuffer.reserveCapacity(totalCount * 2)
        Static.vertexBuffer.removeAll(keepingCapacity: true)
        for f in tempArray{
            Static.vertexBuffer.append(GLfloat(f))
        }
        glBindBuffer(GL_ARRAY_BUFFER.ui, vboId)
        glBufferData(GL_ARRAY_BUFFER.ui, totalCount*2*MemoryLayout<GLfloat>.size, Static.vertexBuffer, GL_DYNAMIC_DRAW.ui)
        
        glEnableVertexAttribArray(ATTRIB_VERTEX.ui)
        glVertexAttribPointer(ATTRIB_VERTEX.ui, 2, GL_FLOAT.ui, GL_FALSE.ub, 0, nil)
        
        // Draw
        glUseProgram(program[PROGRAM_POINT].id)
        glDrawArrays(GL_POINTS.ui, 0, totalCount.i)
        
        
        
    }
    
}
