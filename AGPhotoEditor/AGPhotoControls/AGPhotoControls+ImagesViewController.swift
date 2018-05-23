//
//  AGPhotoControls+ImagesViewController.swift
//  AGPhotoEditor
//
//  Created by Pavel on 17.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import Foundation
import UIKit

extension AGPhotoControlsViewController {
    
    func addImagesViewController() {
        imagesVCIsVisible = true
        self.toolView.isHidden = true
        self.canvasView.isUserInteractionEnabled = false
        imagesViewController.imagesViewControllerDelegate = self
        
        for image in self.images {
            imagesViewController.images.append(image)
        }
        self.addChildViewController(imagesViewController)
        self.view.addSubview(imagesViewController.view)
        imagesViewController.didMove(toParentViewController: self)
        let height = view.frame.height
        let width  = view.frame.width
        imagesViewController.view.frame = CGRect(x: 0, y: self.view.frame.maxY , width: width, height: height)
    }
    
    func removeStickersView() {
        imagesVCIsVisible = false
        self.canvasView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: UIViewAnimationOptions.curveEaseIn,
                       animations: { () -> Void in
                        var frame = self.imagesViewController.view.frame
                        frame.origin.y = UIScreen.main.bounds.maxY
                        self.imagesViewController.view.frame = frame
        }, completion: { (finished) -> Void in
            self.imagesViewController.view.removeFromSuperview()
            self.imagesViewController.removeFromParentViewController()
            self.toolView.isHidden = false
        })
    }
}

extension AGPhotoControlsViewController: AGImagesViewControllerDelegate {
    
    func didSelectImage(image: UIImage) {
        self.removeStickersView()
        self.canvasView.addImage(image: image)
    }
    
    func imagesViewDidDisappear() {
        imagesVCIsVisible = false
        self.canvasView.isUserInteractionEnabled = true
        self.toolView.isHidden = false
    }
}

