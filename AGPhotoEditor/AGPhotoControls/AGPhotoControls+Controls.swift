//
//  AGPhotoControls+Controls.swift
//  AGPhotoEditor
//
//  Created by Pavel on 17.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Control
public enum control {
    case crop
    case sticker
    case draw
    case text
    case save
    case share
    case clear
}

extension AGPhotoControlsViewController {
    
    @IBAction func stickersButtonTapped(_ sender: Any) {
        addImagesViewController()
    }
    
    @IBAction func imagesButtonTapped(_ sender: Any) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func textButtonTapped(_ sender: Any) {
        canvasView.addTextView()
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        canvasView .isDrawing = true
//        canvasView.isUserInteractionEnabled = false
//        doneButton.isHidden = false
//        colorPickerView.isHidden = false
//        hideToolbar(hide: true)
    }

    
}
