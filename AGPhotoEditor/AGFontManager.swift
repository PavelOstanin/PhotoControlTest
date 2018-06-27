//
//  AGFontManager.swift
//  AGPhotoEditor
//
//  Created by Pavel on 19.06.2018.
//  Copyright © 2018 Agilie. All rights reserved.
//

import UIKit
import Alamofire

class AGFontManager {
    
    class func uploadFont(url: String){//

        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        Alamofire.download(url, to: destination)
            .response {
                response in
                if response.destinationURL != nil {
                    let fontData = NSData.init(contentsOf: response.destinationURL!)
                    let dataProvider = CGDataProvider(data: fontData!)
                    let cgFont = CGFont(dataProvider!)
                    var errorFont: Unmanaged<CFError>?
                    if let fontName = cgFont?.postScriptName{
                        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let fileUrl = documentsUrl.appendingPathComponent(String(fontName) + ".ttf")
                        fontData?.write(to: fileUrl, atomically: true)
                    }
                    if CTFontManagerRegisterGraphicsFont(cgFont!, &errorFont) {
                        print("font loaded")
                    }
                }
        }
        
    }
    
    class func registerCurrentFonts(){
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            fileURLs.forEach { url in
                if url.absoluteString.contains(".ttf"){
                    if let fontDataProvider = CGDataProvider(url: url as CFURL) {
                        let font = CGFont(fontDataProvider)
                        var error: Unmanaged<CFError>?
                        CTFontManagerRegisterGraphicsFont(font!, &error)
                    }
                }
            }
        } catch {
            print("Error while enumerating files \(documentsUrl.path): \(error.localizedDescription)")
        }
    }

}
