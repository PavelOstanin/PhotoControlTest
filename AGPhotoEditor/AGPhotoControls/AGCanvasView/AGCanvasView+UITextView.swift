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
        let attributes = textView.getCurrentTextAttributes()
        let newFrame = NSString.init(string: textView.text).boundingRect(with: CGSize.zero, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        textView.superview?.bounds.size = CGSize(width: newFrame.width + 10.0, height: newFrame.height+30)
        textView.frame.size = CGSize(width: newFrame.width + 10.0, height: newFrame.height+30)
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        isTyping = true
        lastTextViewTransform =  textView.superview?.transform
        lastTextViewTransCenter = textView.superview?.center
        activeTextView = textView
        textView.superview?.superview?.bringSubview(toFront: textView)
        UIView.animate(withDuration: 0.3
            ,
                       animations: {
                        textView.superview?.transform = CGAffineTransform.identity
                        textView.superview?.center = CGPoint(x: self.bounds.width / 2,
                                                  y:  self.bounds.height / 5)
        }, completion: nil)
        
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        isTyping = false
        guard lastTextViewTransform != nil && lastTextViewTransCenter != nil
            else {
                return
        }
        activeTextView = nil
        UIView.animate(withDuration: 0.3,
                       animations: {
                        textView.superview?.transform = self.lastTextViewTransform!
                        textView.superview?.center = self.lastTextViewTransCenter!
        }, completion: nil)
    }

}
