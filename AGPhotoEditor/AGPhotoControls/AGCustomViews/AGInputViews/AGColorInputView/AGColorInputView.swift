//
//  AGColorInputView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 23.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGColorInputView: UIView {


    @IBOutlet var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    var colorInputViewDelegate : AGColorInputViewDelegate?
    
    lazy var colors: Array<UIColor> = {
        return colorsDataSource
    }()
    
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
        Bundle.main.loadNibNamed("AGColorInputView", owner: self, options: nil)
        self.addSubview(contentView);
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func commonInit(){
        let nibName = UINib(nibName: "AGColorCollectionViewCell", bundle:nil)
        collectionView.register(nibName, forCellWithReuseIdentifier: "AGColorCollectionViewCell")
        collectionView.reloadData()
    }
    
}

extension AGColorInputView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AGColorCollectionViewCell", for: indexPath) as! AGColorCollectionViewCell
        cell.colorView.backgroundColor = colors[indexPath.row]
        return cell
    }
    
}

extension AGColorInputView : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        colorInputViewDelegate?.didChangeTextColor(color: colors[indexPath.row])
    }
    
}

extension AGColorInputView : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return AGColorCollectionViewCell.cellSize()
    }
    
}
