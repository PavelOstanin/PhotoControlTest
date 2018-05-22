//
//  AGFontCollectionViewCell.swift
//  AGPhotoEditor
//
//  Created by Pavel on 22.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGFontCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var fontNameLabel: UILabel!
    
    class func cellSize() -> CGSize {
        return CGSize.init(width: UIScreen.main.bounds.width / 2, height: 70)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
