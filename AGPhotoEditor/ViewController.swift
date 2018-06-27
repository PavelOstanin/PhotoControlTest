//
//  ViewController.swift
//  AGPhotoEditor
//
//  Created by Pavel on 17.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        AGFontManager.uploadFont(url: "http://dev.agilie.com/Spirax-Regular.ttf")
        AGFontManager.registerCurrentFonts()
    }

    @IBAction func startPhotoEditorDidTouch(_ sender: Any) {
        let photoEditor = AGPhotoControlsViewController(nibName:"AGPhotoControlsViewController",bundle: Bundle(for: AGPhotoControlsViewController.self))
//        photoEditor.photoEditorDelegate = self
//        photoEditor.image = image
        //Colors for drawing and Text, If not set default values will be used
        //photoEditor.colors = [.red, .blue, .green]
        
        //Stickers that the user will choose from to add on the image
        for i in 0...10 {
            photoEditor.images.append(UIImage(named: i.description )!)
        }
        
        //To hide controls - array of enum control
        //photoEditor.hiddenControls = [.crop, .draw, .share]
        
        present(photoEditor, animated: true, completion: nil)
    }
    
    
}

