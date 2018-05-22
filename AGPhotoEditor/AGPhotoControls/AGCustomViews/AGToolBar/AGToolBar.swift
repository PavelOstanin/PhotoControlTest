//
//  AGToolBar.swift
//  AGPhotoEditor
//
//  Created by Pavel on 22.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGToolBar: UIView {
    
    var toolBarDelegate : AGToolBarDelegate?

    @IBOutlet var toolBarView: UIView!
    var textView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        Bundle.main.loadNibNamed("AGToolBar", owner: self, options: nil)
        self.addSubview(toolBarView);
        toolBarView.frame = bounds
        toolBarView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }

    @IBAction func keyboardType(_ sender: Any) {
        toolBarDelegate?.didChangeInputView(type: .keyboard)
    }
    
    @IBAction func fontType(_ sender: Any) {
        toolBarDelegate?.didChangeInputView(type: .font)
    }
    
    @IBAction func formatType(_ sender: Any) {
        toolBarDelegate?.didChangeInputView(type: .format)
    }
    
    @IBAction func colorType(_ sender: Any) {
        toolBarDelegate?.didChangeInputView(type: .color)
    }
    
}
