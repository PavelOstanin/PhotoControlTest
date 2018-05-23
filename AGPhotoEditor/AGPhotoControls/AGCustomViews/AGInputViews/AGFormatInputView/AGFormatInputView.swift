//
//  AGFormatInputView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 23.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGFormatInputView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var sizeSliderView: UISlider!
    @IBOutlet weak var heightSliderView: UISlider!
    @IBOutlet weak var spacingSliderView: UISlider!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("AGFormatInputView", owner: self, options: nil)
        self.addSubview(contentView);
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    
    @IBAction func leftAlignmentDidTouch(_ sender: Any) {
    }
    
    @IBAction func centerAlignmentDidTouch(_ sender: Any) {
    }
    
    @IBAction func rightAlignmentDidTouch(_ sender: Any) {
    }
    
    @IBAction func sizeSliderDidChange(_ sender: Any) {
    }
    
    @IBAction func heightSliderDidChange(_ sender: Any) {
    }
    
    @IBAction func spacingSliserDidChange(_ sender: Any) {
    }
    
    
    
}
