//
//  AGCanvasView+Keyboard.swift
//  AGPhotoEditor
//
//  Created by Pavel on 18.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import Foundation
import UIKit

extension AGCanvasView {
    
    func keyboardDidShow(notification: NSNotification) {
        if isTyping {
//            doneButton.isHidden = false
//            colorPickerView.isHidden = false
//            hideToolbar(hide: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        isTyping = false
//        doneButton.isHidden = true
//        hideToolbar(hide: false)
    }
    
    func keyboardWillChangeFrame(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
//            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
//                self.colorPickerViewBottomConstraint?.constant = 0.0
//            } else {
//                self.colorPickerViewBottomConstraint?.constant = endFrame?.size.height ?? 0.0
//            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
}


