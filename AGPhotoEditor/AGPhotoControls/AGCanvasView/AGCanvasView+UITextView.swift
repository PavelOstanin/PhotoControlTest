//
//  AGCanvasView+UITextView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 18.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import Foundation
import UIKit

extension AGCanvasView: UITextViewDelegate {
    
    public func textViewDidChange(_ textView: UITextView) {
        let oldFrame = textView.bounds
        let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height:CGFloat.greatestFiniteMagnitude))
        textView.bounds.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        lastTextViewTransform =  textView.transform
        lastTextViewTransCenter = textView.center
        activeTextView = textView
        textView.superview?.bringSubview(toFront: textView)
        UIView.animate(withDuration: 0.3
            ,
                       animations: {
                        textView.transform = CGAffineTransform.identity
                        textView.center = CGPoint(x: UIScreen.main.bounds.width / 2,
                                                  y:  UIScreen.main.bounds.height / 5)
        }, completion: nil)
        
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil && lastTextViewFont != nil
            else {
                return
        }
        activeTextView = nil
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.transform = self.lastTextViewTransform!
                        textView.center = self.lastTextViewTransCenter!
        }, completion: nil)
    }

}
