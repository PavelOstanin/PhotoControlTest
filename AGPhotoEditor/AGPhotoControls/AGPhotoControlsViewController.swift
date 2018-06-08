//
//  AGPhotoControlsViewController.swift
//  AGPhotoEditor
//
//  Created by Pavel on 17.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGPhotoControlsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var drawSizeView: UIView!
    
    @IBOutlet weak var drawToolView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var canvasView: AGCanvasView!
    let imagePicker = UIImagePickerController()
    /**
     Array of Stickers -UIImage- that the user will choose from
     */
    public var images : [UIImage] = []
    
    var imagesVCIsVisible = false
    var imagesViewController: AGImagesViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        canvasView.canvasViewDelegate = self
        imagePicker.delegate = self
        imagesViewController = AGImagesViewController(nibName: "AGImagesViewController", bundle: Bundle(for: AGImagesViewController.self))
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.canvasView.addImage(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion:nil)
    }

}

extension AGPhotoControlsViewController: AGCanvasViewDelegate {
    
    func didChangeEditMode(mode: EditMode) {
        doneButton.isHidden = false
        toolView.isHidden = true
        if mode == .draw{
            drawSizeView.isHidden = false
            drawToolView.isHidden = false
        }
    }
    
    func didFinishEdit() {
        drawSizeView.isHidden = true
        drawToolView.isHidden = true
        doneButton.isHidden = true
        toolView.isHidden = false
    }
    
}
