//
//  AGPhotoControls+Gestures.swift
//  AGPhotoEditor
//
//  Created by Pavel on 17.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import Foundation
import UIKit

extension AGCanvasView : UIGestureRecognizerDelegate {
    
    /**
     UIPanGestureRecognizer - Moving Objects
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func panGesture(_ recognizer: UIPanGestureRecognizer) {
        if let view = recognizer.view {
            moveView(view: view, recognizer: recognizer)
        }
    }
    
    /**
     UIPinchGestureRecognizer - Pinching Objects
     If it's a UITextView will make the font bigger so it doen't look pixlated
     */
    @objc func pinchGesture(_ recognizer: UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            if view is UITextView {
                let textView = view as! UITextView
                if (recognizer.state == .ended
                    || recognizer.state == .changed) {
                    
                    var attributes = textView.getCurrentTextAttributes()
                    let font = attributes[NSAttributedStringKey.font] as! UIFont
                    
                    let currentFontSize = font.pointSize;
                    var newScale = currentFontSize * recognizer.scale;
                    
                    
                    if (newScale < constMinimumFontSize) {
                        newScale = constMinimumFontSize;
                    }
                    if (newScale > constMaximumFontSize) {
                        newScale = constMaximumFontSize;
                    }
                    
                    attributes[NSAttributedStringKey.font] = UIFont.init(name: font.fontName, size: newScale)
                    textView.attributedText = NSAttributedString(string: textView.text ?? "", attributes: attributes)
                    recognizer.scale = 1;
                    self.textViewDidChange(textView)
                    
                }
            } else {
                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            }
            recognizer.scale = 1
        }
    }
    
    /**
     UIRotationGestureRecognizer - Rotating Objects
     */
    @objc func rotationGesture(_ recognizer: UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    /**
     UITapGestureRecognizer - Taping on Objects
     Will make scale scale Effect
     Selecting transparent parts of the imageview won't move the object
     */
    @objc func tapGesture(_ recognizer: UITapGestureRecognizer) {
        for imageView in self.contentView.subviews{
            if imageView is UIImageView {
                let location = recognizer.location(in: imageView)
                let alpha = (imageView as! UIImageView).alphaAtPoint(location)
                if alpha > 0 {
                    scaleEffect(view: imageView)
                    break
                }
            }
            else{
                let location = recognizer.location(in: imageView.superview)
                if imageView.frame.contains(location){
                    scaleEffect(view: imageView)
                    break
                }
            }
        }
    }
    
    @objc func dismissKeyboard(){
        endEditing(false)
        canvasViewDelegate?.didFinishEdit()
    }
    
    /*
     Support Multiple Gesture at the same time
     */
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = gestureRecognizer.view {
            if view == self {
                if isTyping {
                    if (touch.view?.isDescendant(of: activeTextView!))! {
                        return false;
                    }
                    return true
                }
                else{
                    return false
                }
            }
//            else if view is UITextView{
//                if isTyping {
//                    if (touch.view?.isDescendant(of: activeTextView!))! {
//                        return false;
//                    }
//                    return true
//                }
//                else{
//                    return true
//                }
//            }
//            return true
        }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    /**
     Scale Effect
     */
    func scaleEffect(view: UIView) {
        view.superview?.bringSubview(toFront: view)
        
        if #available(iOS 10.0, *) {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
        let previouTransform =  view.transform
        UIView.animate(withDuration: 0.2,
                       animations: {
                        view.transform = view.transform.scaledBy(x: 1.2, y: 1.2)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.2) {
                            view.transform  = previouTransform
                        }
        })
    }
    
    /**
     Moving Objects
     delete the view if it's inside the delete view
     Snap the view back if it's out of the canvas
     */
    
    func moveView(view: UIView, recognizer: UIPanGestureRecognizer)  {
    
//        canvasViewDelegate?.didChangeEditStatus(status: true)
        deleteView.isHidden = false

        view.superview?.bringSubview(toFront: view)
        let pointToSuperView = recognizer.location(in: self.contentView)

        view.center = CGPoint(x: view.center.x + recognizer.translation(in: self).x,
                              y: view.center.y + recognizer.translation(in: self).y)

        recognizer.setTranslation(CGPoint.zero, in: self)

        if let previousPoint = lastPanPoint {
            //View is going into deleteView
            if deleteView.frame.contains(pointToSuperView) && !deleteView.frame.contains(previousPoint) {
                if #available(iOS 10.0, *) {
                    let generator = UIImpactFeedbackGenerator(style: .heavy)
                    generator.impactOccurred()
                }
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 0.25, y: 0.25)
                    view.center = recognizer.location(in: self.contentView)
                })
            }
                //View is going out of deleteView
            else if deleteView.frame.contains(previousPoint) && !deleteView.frame.contains(pointToSuperView) {
                //Scale to original Size
                UIView.animate(withDuration: 0.3, animations: {
                    view.transform = view.transform.scaledBy(x: 4, y: 4)
                    view.center = recognizer.location(in: self.contentView)
                })
            }
        }
        lastPanPoint = pointToSuperView

        if recognizer.state == .ended {
            lastPanPoint = nil
//            canvasViewDelegate?.didChangeEditStatus(status: false)
            deleteView.isHidden = true
            let point = recognizer.location(in: self.contentView)

            if deleteView.frame.contains(point) { // Delete the view
                view.removeFromSuperview()
                if #available(iOS 10.0, *) {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            } else if !self.bounds.contains(view.center) { //Snap the view back to canvasImageView
                UIView.animate(withDuration: 0.3, animations: {
                    view.center = self.center
                })

            }
        }
    }
    
    func subImageViews(view: UIView) -> [UIImageView] {
        var imageviews: [UIImageView] = []
        for imageView in view.subviews {
            if imageView is UIImageView {
                imageviews.append(imageView as! UIImageView)
            }
        }
        return imageviews
    }
    
}
