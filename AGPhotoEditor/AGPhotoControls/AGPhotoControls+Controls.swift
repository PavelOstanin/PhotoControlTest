//
//  AGPhotoControls+Controls.swift
//  AGPhotoEditor
//
//  Created by Pavel on 17.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import Foundation
import UIKit

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
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        view.endEditing(true)
        didFinishEdit()
        canvasView.contentView.isUserInteractionEnabled = true
        canvasView.isDrawing = false
    }
    
    @IBAction func drawButtonTapped(_ sender: Any) {
        canvasView.isDrawing = true
        canvasView.contentView.isUserInteractionEnabled = false
        didChangeEditMode(mode: .draw)
    }
    
    @IBAction func repoTapped(_ sender: Any) {
        canvasView.redo()
    }
    
    @IBAction func undoTapped(_ sender: Any) {
        canvasView.undo()
    }
    
    @IBAction func clearTapped(_ sender: Any) {
        canvasView.clearDrawing()
    }

    
}
