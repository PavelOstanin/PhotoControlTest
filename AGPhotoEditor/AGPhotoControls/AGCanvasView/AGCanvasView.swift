//
//  AGCanvasView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 18.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGCanvasView: UIView {
    

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var deleteView: UIView!
    var lastPanPoint: CGPoint?
    var isTyping: Bool = false
    
    var lastTextViewTransform: CGAffineTransform?
    var lastTextViewTransCenter: CGPoint?
    var lastTextViewFont:UIFont?
    var activeTextView: UITextView?
    
    var isDrawing: Bool = false
    var lastPoint: CGPoint!
    var swiped = false
    
    var keyboardHeight: CGFloat = 0
    
    @IBOutlet weak var imageViewForDraw: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        Bundle.main.loadNibNamed("AGCanvasView", owner: self, options: nil)
        self.addSubview(contentView);
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: .UIKeyboardDidShow, object: nil)
    }
    
    func addImage(image: UIImage){
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: 150, height: 150)
        imageView.center = center
        
        self.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
    }
    
    func addTextView() {
        isTyping = true
        let textView = UITextView(frame: CGRect(x: 0, y: center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        
        textView.textAlignment = .center
        textView.font = UIFont(name: "Helvetica", size: 30)
        textView.textColor = UIColor.red
        textView.layer.shadowColor = UIColor.black.cgColor
        textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
        textView.layer.shadowOpacity = 0.2
        textView.layer.shadowRadius = 1.0
        textView.layer.backgroundColor = UIColor.clear.cgColor
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        let view = AGToolBar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 45))
        view.toolBarDelegate = self
        view.textView = textView
        textView.inputAccessoryView = view
        addSubview(textView)
        addGestures(view: textView)
        textView.becomeFirstResponder()

    }
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(AGCanvasView.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(AGCanvasView.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(AGCanvasView.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AGCanvasView.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
    }
    
}

extension AGCanvasView: AGToolBarDelegate{
    
    func didChangeInputView(type: KeyboardType){
        switch type {
        case .keyboard:
            activeTextView?.inputView = nil
        case .font:
            let view = AGFontInputView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: keyboardHeight))
            view.fontInputViewDelegate = self
            activeTextView?.inputView = view
        case .format:
            activeTextView?.inputView = nil
        case .color:
            activeTextView?.inputView = nil
        default:
            activeTextView?.inputView = nil
        }
        activeTextView?.reloadInputViews()
    }
    
}

extension AGCanvasView: AGFontInputViewDelegate {
    
    func didChangeTextFont(fontName: String) {
        activeTextView?.font = UIFont.init(name: fontName, size: (activeTextView?.font?.pointSize)!)
    }
    
    func didChangeTextColor(color: UIColor) {
        
    }
    
}
