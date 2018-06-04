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
    var formatInputViewDelegate : AGFormatInputViewDelegate?
    
    convenience init(textView: UITextView, frame: CGRect){
        self.init(frame: frame)
        self.setupWithTextView(textView: textView)
        self.setupConstValue()
    }
    
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
    
    private func setupWithTextView(textView: UITextView){
        var attributes = textView.getCurrentTextAttributes()
        let fontSize = textView.font?.pointSize
        let height = textView.getCurrentTextParagraphStyle().lineSpacing
        let spacing = attributes[NSAttributedStringKey.kern]
        sizeSliderView.value = Float(fontSize!)
        heightSliderView.value = Float(height)
        spacingSliderView.value = Float(spacing as! CGFloat)
    }
    
    private func setupConstValue(){
        sizeSliderView.minimumValue = Float(constMinimumFontSize)
        sizeSliderView.maximumValue = Float(constMaximumFontSize)
        heightSliderView.minimumValue = Float(constMinimumFontHeight)
        heightSliderView.maximumValue = Float(constMaximumFontHeight)
        spacingSliderView.minimumValue = Float(constMinimumFontSpace)
        spacingSliderView.maximumValue = Float(constMaximumFontSpace)
    }
    
    @IBAction func leftAlignmentDidTouch(_ sender: Any) {
        formatInputViewDelegate?.didChangeTextAlignment(alignment: .left)
    }
    
    @IBAction func centerAlignmentDidTouch(_ sender: Any) {
        formatInputViewDelegate?.didChangeTextAlignment(alignment: .center)
    }
    
    @IBAction func rightAlignmentDidTouch(_ sender: Any) {
        formatInputViewDelegate?.didChangeTextAlignment(alignment: .right)
    }
    
    @IBAction func sizeSliderDidChange(_ sender: UISlider) {
        formatInputViewDelegate?.didChangeTextSize(size: CGFloat(sender.value))
    }
    
    @IBAction func heightSliderDidChange(_ sender: UISlider) {
        formatInputViewDelegate?.didChangeTextHeight(height: CGFloat(sender.value))
    }
    
    @IBAction func spacingSliserDidChange(_ sender: UISlider) {
        formatInputViewDelegate?.didChangeTextSpacing(space: CGFloat(sender.value))
    }
    
}
