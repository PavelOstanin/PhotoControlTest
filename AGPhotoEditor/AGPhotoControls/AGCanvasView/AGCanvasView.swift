//
//  AGCanvasView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 18.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

// MARK: - Control
public enum EditMode {
    case sticker
    case draw
    case text
    case image
}


public protocol AGCanvasViewDelegate {
    
    func didChangeEditMode(mode: EditMode)
    func didFinishEdit()
    
}

class AGCanvasView: UIView {
    
    var canvasViewDelegate : AGCanvasViewDelegate?
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
    
    var brush = AGBrush()
    let session = AGDrawSession()
    var drawing = AGDrawing()
    let path = UIBezierPath()
    let scale = UIScreen.main.scale
    
    var tempImageView = UIImageView()
    
    var saved = false
    var pointMoved = false
    var pointIndex = 0
    var points = [CGPoint?](repeating: CGPoint.zero, count: 5)
    
    @IBOutlet weak var imageViewForDraw: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        Bundle.main.loadNibNamed("AGCanvasView", owner: self, options: nil)
        self.addSubview(contentView)
        self.addSubview(imageViewForDraw)
        self.addSubview(self.tempImageView)
        self.addSubview(deleteView)
        imageViewForDraw.frame = self.bounds
        tempImageView.frame = self.bounds
        contentView.frame = self.bounds
        deleteView.frame = CGRect.init(x: self.bounds.size.width - deleteView.frame.size.width, y: self.bounds.size.height - deleteView.frame.size.height, width: deleteView.frame.size.width, height: deleteView.frame.size.height)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: .UIKeyboardDidShow, object: nil)
    }
    
    func addImage(image: UIImage){
        let imageView = UIImageView(image: image)
        var imageSize = image.size
        if image.size.height/bounds.size.height > image.size.width/bounds.size.width {
            imageSize = CGSize.init(width: image.size.width * (bounds.size.height/image.size.height), height: bounds.height)
        }
        else {
            imageSize = CGSize.init(width: bounds.width, height: image.size.height * (bounds.size.width/image.size.width))
        }
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = imageSize
        imageView.center = contentView.center
        
        self.contentView.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
    }
    
    func addTextView() {
        isTyping = true
        let textView = UITextView(frame: CGRect(x: 0, y: center.y,
                                                width: UIScreen.main.bounds.width, height: 30))
        
        textView.textAlignment = .center
        textView.font = UIFont(name: constTextFontName, size: constTextFontSize)
        textView.textColor = constTextColor
        textView.backgroundColor = UIColor.clear
        textView.autocorrectionType = .no
        textView.isScrollEnabled = false
        textView.delegate = self
        let view = AGToolBar.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 45))
        view.toolBarDelegate = self
        view.textView = textView
        textView.inputAccessoryView = view
        contentView.addSubview(textView)
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
        
        if !(view is UITextView){
            let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                        action: #selector(AGCanvasView.pinchGesture))
            pinchGesture.delegate = self
            view.addGestureRecognizer(pinchGesture)
        }
    
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(AGCanvasView.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        view.addGestureRecognizer(rotationGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AGCanvasView.tapGesture))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    func clearDrawImage() {
        self.imageViewForDraw.layer.sublayers?.removeAll()
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
            let view = AGFormatInputView.init(textView: activeTextView!, frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: keyboardHeight))
            view.formatInputViewDelegate = self
            activeTextView?.inputView = view
        case .color:
            let view = AGColorInputView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: keyboardHeight))
            view.colorInputViewDelegate = self
            activeTextView?.inputView = view
        default:
            activeTextView?.inputView = nil
        }
        activeTextView?.reloadInputViews()
    }
    
}


