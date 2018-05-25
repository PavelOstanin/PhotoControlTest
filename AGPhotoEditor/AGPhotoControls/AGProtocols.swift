//
//  AGProtocols.swift
//  AGPhotoEditor
//
//  Created by Pavel on 17.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import Foundation
import UIKit


/**
 - didSelectImage
 - imagesViewDidDisappear
 */
protocol AGImagesViewControllerDelegate {
    /**
     - Parameter image: selected Image from ImagesViewController
     */
    func didSelectImage(image: UIImage)
    /**
     ImagesViewController did Disappear
     */
    func imagesViewDidDisappear()
}
