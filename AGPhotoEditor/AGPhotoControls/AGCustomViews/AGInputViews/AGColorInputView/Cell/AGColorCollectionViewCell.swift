//
//  AGColorCollectionViewCell.swift
//  AGPhotoEditor
//
//  Created by Pavel on 23.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGColorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var selectetedImageView: UIImageView!
    @IBOutlet weak var colorView: UIView!
    
    class func cellSize() -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width / 7, height: 70)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.colorView.layer.cornerRadius = self.colorView.bounds.size.width / 2
        self.colorView.layer.masksToBounds = true
    }

}
