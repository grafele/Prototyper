//
//  PrototypeController.swift
//  PrototypeFrameWork
//
//  Created by Stefan Kofler on 28.05.16.
//  Copyright © 2016 Stefan Kofler. All rights reserved.
//

import Foundation
import NSHash
import SSZipArchive
import GCDWebServer

open class PrototypeController: NSObject {
    open static let sharedInstance = PrototypeController()
    fileprivate static var webServer: GCDWebServer!

    fileprivate static let PrototypeControllerMD5HashKey = "PrototypeControllerMD5HashKey"
    
    fileprivate var completionHandler: ((Void) -> Void)?
    
    open func preloadPrototypes(_ completionHandler: ((Void) -> Void)?) {
        let containerPath = Bundle.main.path(forResource: "container", ofType: "zip")!
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        unzipContainerIfNecessary(containerPath, documentsPath: documentsPath)
        startWebServerForPath(documentsPath) {
            completionHandler?()
        }
    }
    
    open func prototypePathForPageId(_ pageId: String, completionHandler: @escaping (_ prototypePath: String) -> Void) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        preloadPrototypes {
            completionHandler("\(self.prototypePathInDirectory(documentsPath) ?? "")?exp=1#\(pageId)")
        }
    }
    
    fileprivate func unzipContainerIfNecessary(_ containerPath: String, documentsPath: String) {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: containerPath)) else { return }
   
        let md5String = (data as NSData).md5().description
        let oldMD5String = UserDefaults.standard.string(forKey: PrototypeController.PrototypeControllerMD5HashKey)
        if oldMD5String == nil || md5String != oldMD5String! {
            SSZipArchive.unzipFile(atPath: containerPath, toDestination: documentsPath)
            UserDefaults.standard.set(md5String, forKey: PrototypeController.PrototypeControllerMD5HashKey)
        }
    }

    fileprivate func startWebServerForPath(_ directoryPath: String, completionHandler: @escaping (Void) -> Void) {
        guard PrototypeController.webServer == nil else {
            completionHandler()
            return
        }
        
        self.completionHandler = completionHandler
        
        GCDWebServer.setLogLevel(3)

        PrototypeController.webServer = GCDWebServer()
        PrototypeController.webServer.delegate = self
        PrototypeController.webServer.addGETHandler(forBasePath: "/", directoryPath: directoryPath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        PrototypeController.webServer.start(withPort: 8080, bonjourName: "Bonjour")
    }
    
    fileprivate func prototypePathInDirectory(_ directoryPath: String) -> String? {
        let contents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath)
        guard let filenames = contents else { return nil }
        
        for filename in filenames where NumberFormatter().number(from: filename) != nil {
            return "http://localhost:8080/\(filename)/marvelapp.com/index.html"
        }
        
        return nil
    }
}

// MARK: - GCDWebServerDelegate

extension PrototypeController: GCDWebServerDelegate {
    public func webServerDidStart(_ server: GCDWebServer!) {
        self.completionHandler?()
    }
}
