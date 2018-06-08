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
        canvasView.setBrushColor(red: 1, green: 0, blue: 0)
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
    
    @IBAction func drawChangeColorTapped(_ sender: UIButton) {
        canvasView.settings.color = CIColor.init(red: (sender.tag == 1 ? 1 : 0), green: (sender.tag == 2 ? 1 : 0), blue: (sender.tag == 3 ? 1 : 0), alpha: 1)
    }
    
    @IBAction func drawWidthDidChange(_ sender: UISlider) {
        canvasView.settings.width = CGFloat(sender.value)
    }

    
}
