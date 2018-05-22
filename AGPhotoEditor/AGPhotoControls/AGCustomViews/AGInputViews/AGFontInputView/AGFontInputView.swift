//
//  AGFontInputView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 22.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGFontInputView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var fonts = Array<String>()
    var fontInputViewDelegate : AGFontInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
        commonInit()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("AGFontInputView", owner: self, options: nil)
        self.addSubview(contentView);
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func commonInit(){
        let nibName = UINib(nibName: "AGFontCollectionViewCell", bundle:nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "AGFontCollectionViewCell")
        fonts = ["Helvetica","AvenirNext-Regular","Kefa-Regular","Menlo-Regular"]
        collectionView.reloadData()
        
    }

}

extension AGFontInputView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fonts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AGFontCollectionViewCell", for: indexPath) as! AGFontCollectionViewCell
        cell.fontNameLabel.font = UIFont.init(name: fonts[indexPath.row], size: 17)
        print(cell.fontNameLabel.font.fontName)
        return cell
    }
    
}

extension AGFontInputView : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        fontInputViewDelegate?.didChangeTextFont(fontName: fonts[indexPath.row])
    }
    
}

extension AGFontInputView : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return AGFontCollectionViewCell.cellSize()
    }
    
}
