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
        if isDrawing {
            swiped = false
            if let touch = touches.first {
                lastPoint = touch.location(in: self)
            }
        }
            //Hide stickersVC if clicked outside it
//        else if stickersVCIsVisible == true {
//            if let touch = touches.first {
//                let location = touch.location(in: self.view)
//                if !stickersViewController.view.frame.contains(location) {
//                    removeStickersView()
//                }
//            }
//        }
        
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            // 6
            swiped = true
            if let touch = touches.first {
                let currentPoint = touch.location(in: self)
                drawLineFrom(lastPoint, toPoint: currentPoint)
                
                // 7
                lastPoint = currentPoint
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>,
                                      with event: UIEvent?){
        if isDrawing {
            if !swiped {
                // draw a single point
                drawLineFrom(lastPoint, toPoint: lastPoint)
            }
        }
        
    }
    
    func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
        // 1
//        UIGraphicsBeginImageContext(self.frame.size)
//        if let context = UIGraphicsGetCurrentContext() {
////            let imageView = UIImageView.init(frame: self.bounds)
////            imageView.image?.draw(in: self.bounds)
//            // 2
//            context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
//            context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
//            // 3
//            context.setLineCap( CGLineCap.round)
//            context.setLineWidth(5.0)
//            context.setStrokeColor(UIColor.green.cgColor)
//            context.setBlendMode( CGBlendMode.normal)
//            // 4
//            context.strokePath()
//            // 5
////            imageView.image = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//        }
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
        linePath.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
        line.path = linePath.cgPath
        line.strokeColor = UIColor.red.cgColor
        line.lineWidth = 5
        line.lineJoin = kCALineJoinRound
        line.lineCap = kCALineCapRound
        self.imageViewForDraw.layer.addSublayer(line)
        
        
    }


}
