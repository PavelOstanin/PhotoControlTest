//
//  AGCanvasView.swift
//  AGPhotoEditor
//
//  Created by Pavel on 18.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit
import GLKit

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
    
    var backingWidth: GLint = 0
    var backingHeight: GLint = 0
    
    var context: EAGLContext!
    
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    var viewRenderbuffer: GLuint = 0, viewFramebuffer: GLuint = 0
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    var depthRenderbuffer: GLuint = 0
    
    var brushTexture: textureInfo_t = (0, 0, 0)     // brush texture
    var brushColor: [GLfloat] = [0, 0, 0, 0]          // brush color
    
    var firstTouch: Bool = false
    var needsErase: Bool = false
    
    // Shader objects
    var vertexShader: GLuint = 0
    var fragmentShader: GLuint = 0
    var shaderProgram: GLuint = 0
    
    // Buffer Objects
    var vboId: GLuint = 0
    
    var initialized: Bool = false
    
    var location: CGPoint = CGPoint()
    var previousLocation: CGPoint = CGPoint()
    
    // Implement this to override the default layer class (which is [CALayer class]).
    // We do this so that our view will be backed by a layer that is capable of OpenGL ES rendering.
    override class var layerClass : AnyClass {
        return CAEAGLLayer.self
    }

    
    
    
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
    
    /// Should be set in whichever class is using the TouchDrawView
    open weak var delegate: AGCanvasDrawViewDelegate?
    
    /// Used to register undo and redo actions
    var drawUndoManager: UndoManager!
    
    /// Used to keep track of all the strokes
    var stack: [AGStroke]!
    
    /// Used to keep track of the current StrokeSettings
    var settings: AGStrokeSettings!
    
    @IBOutlet weak var imageViewForDraw: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    private func setup() {
        Bundle.main.loadNibNamed("AGCanvasView", owner: self, options: nil)
        self.addSubview(contentView)
        self.addSubview(imageViewForDraw)
        self.addSubview(deleteView)
        imageViewForDraw.frame = self.bounds
        contentView.frame = self.bounds
        deleteView.frame = CGRect.init(x: self.bounds.size.width - deleteView.frame.size.width, y: self.bounds.size.height - deleteView.frame.size.height, width: deleteView.frame.size.width, height: deleteView.frame.size.height)
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow),
                                               name: .UIKeyboardDidShow, object: nil)
        imageViewForDraw.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        deleteView.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin]
        stack = []
        settings = AGStrokeSettings()
        drawUndoManager = undoManager
        if drawUndoManager == nil {
            drawUndoManager = UndoManager()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AGCanvasView.dismissKeyboard))
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
        
        let eaglLayer = self.layer as! CAEAGLLayer

        eaglLayer.isOpaque = true
        // In this application, we want to retain the EAGLDrawable contents after a call to presentRenderbuffer.
        eaglLayer.drawableProperties = [
            kEAGLDrawablePropertyRetainedBacking: true,
            kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]

        context = EAGLContext(api: .openGLES2)

        if context == nil || !EAGLContext.setCurrent(context) {
            fatalError("EAGLContext cannot be created")
        }
        
        // Set the view's scale factor as you wish
        self.contentScaleFactor = UIScreen.main.scale

        // Make sure to start with a cleared buffer
        needsErase = true
    }
    
    func addImage(image: UIImage){
        let imageView = UIImageView(image: image)
        var imageSize = image.size
        let maxSize = CGSize(width: bounds.size.width / 2, height: bounds.size.height / 2)
        if image.size.height/maxSize.height > image.size.width/maxSize.width {
            imageSize = CGSize.init(width: image.size.width * (maxSize.height/image.size.height), height: maxSize.height)
        }
        else {
            imageSize = CGSize.init(width: maxSize.width, height: image.size.height * (maxSize.width/image.size.width))
        }
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = imageSize
        imageView.center = contentView.center
        
        self.contentView.addSubview(imageView)
        //Gestures
        addGestures(view: imageView)
    }
    
    func addTextView() {
        let mainView = UIView(frame: CGRect(x: 0, y: center.y,
                                                width: bounds.width, height: 30))
        mainView.backgroundColor = UIColor.clear
        let textView = UITextView(frame: CGRect(x: 0, y: 0,
                                                width: bounds.width, height: 30))
        mainView.center = CGPoint(x: self.bounds.width / 2,
                                  y:  self.bounds.height / 5)
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
        contentView.addSubview(mainView)
        mainView.addSubview(textView)
        
        addGestures(view: textView)
        textView.becomeFirstResponder()

    }
    
    func addGestures(view: UIView) {
        //Gestures
        view.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self,
                                                action: #selector(AGCanvasView.panGesture))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        panGesture.delegate = self
        if view is UITextView {
            view.superview?.addGestureRecognizer(panGesture)
        }
        else{
            view.addGestureRecognizer(panGesture)
        }
        
        let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                    action: #selector(AGCanvasView.pinchGesture))
        pinchGesture.delegate = self
        view.addGestureRecognizer(pinchGesture)
    
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                    action:#selector(AGCanvasView.rotationGesture) )
        rotationGestureRecognizer.delegate = self
        if view is UITextView {
            view.superview?.addGestureRecognizer(rotationGestureRecognizer)
        }
        else{
            view.addGestureRecognizer(rotationGestureRecognizer)
        }
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AGCanvasView.tapGesture))
//        tapGesture.delegate = self
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


