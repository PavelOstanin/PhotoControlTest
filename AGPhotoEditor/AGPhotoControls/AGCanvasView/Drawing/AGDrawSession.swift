//
//  AGDrawSession.swift
//  AGPhotoEditor
//
//  Created by Pavel on 29.05.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit

class AGDrawSession: NSObject {
    
    fileprivate let maxSessionSize = 50
    fileprivate var undoSessionList = [AGDrawing]()
    fileprivate var redoSessionList = [AGDrawing]()
    fileprivate var backgroundSession: AGDrawing?
    
    override init() {
        super.init()
    }
    
    // MARK: - Private Methods
    fileprivate func appendUndo(_ session: AGDrawing?) {
        if session == nil {
            return
        }
        
        if self.undoSessionList.count >= self.maxSessionSize {
            self.undoSessionList.removeFirst()
        }
        
        self.undoSessionList.append(session!)
    }
    
    fileprivate func appendRedo(_ session: AGDrawing?) {
        if session == nil {
            return
        }
        
        if self.redoSessionList.count >= self.maxSessionSize {
            self.redoSessionList.removeFirst()
        }
        
        self.redoSessionList.append(session!)
    }
    
    fileprivate func resetUndo() {
        self.undoSessionList.removeAll()
    }
    
    fileprivate func resetRedo() {
        self.redoSessionList.removeAll()
    }
    
    // MARK: - Public Methods
    @objc func lastSession() -> AGDrawing? {
        if self.undoSessionList.last != nil {
            return self.undoSessionList.last
        } else if self.backgroundSession != nil {
            return self.backgroundSession
        }
        
        return nil
    }
    
    @objc func appendBackground(_ session: AGDrawing?) {
        if session != nil {
            self.backgroundSession = session
        }
    }
    
    @objc func append(_ session: AGDrawing?) {
        self.appendUndo(session)
        self.resetRedo()
    }
    
    @objc func undo() {
        let lastSession = self.undoSessionList.last
        if (lastSession != nil) {
            self.appendRedo(lastSession!)
            self.undoSessionList.removeLast()
        }
    }
    
    @objc func redo() {
        let lastSession = self.redoSessionList.last
        if (lastSession != nil) {
            self.appendUndo(lastSession!)
            self.redoSessionList.removeLast()
        }
    }
    
    @objc func clear() {
        self.resetUndo()
        self.resetRedo()
    }
    
    @objc func canUndo() -> Bool {
        return self.undoSessionList.count > 0
    }
    
    @objc func canRedo() -> Bool {
        return self.redoSessionList.count > 0
    }
    
    @objc func canReset() -> Bool {
        return (self.canUndo() || self.canRedo())
    }
}
