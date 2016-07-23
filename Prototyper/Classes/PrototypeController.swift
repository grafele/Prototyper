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

public class PrototypeController: NSObject {
    public static let sharedInstance = PrototypeController()
    private static var webServer: GCDWebServer!

    private static let PrototypeControllerMD5HashKey = "PrototypeControllerMD5HashKey"
    
    private var completionHandler: (Void -> Void)?
    
    public func preloadPrototypes(completionHandler: ((Void) -> Void)?) {
        let containerPath = NSBundle.mainBundle().pathForResource("container", ofType: "zip")!
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        unzipContainerIfNecessary(containerPath, documentsPath: documentsPath)
        startWebServerForPath(documentsPath) {
            completionHandler?()
        }
    }
    
    public func prototypePathForPageId(pageId: String, completionHandler: (prototypePath: String) -> Void) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        preloadPrototypes {
            completionHandler(prototypePath: "\(self.prototypePathInDirectory(documentsPath))?exp=1#\(pageId)")
        }
    }
    
    private func unzipContainerIfNecessary(containerPath: String, documentsPath: String) {
        guard let data = NSData(contentsOfFile: containerPath) else { return }
   
        let md5String = data.MD5().description
        let oldMD5String = NSUserDefaults.standardUserDefaults().stringForKey(PrototypeController.PrototypeControllerMD5HashKey)
        if oldMD5String == nil || md5String != oldMD5String! {
            SSZipArchive.unzipFileAtPath(containerPath, toDestination: documentsPath)
            NSUserDefaults.standardUserDefaults().setObject(md5String, forKey: PrototypeController.PrototypeControllerMD5HashKey)
        }
    }

    private func startWebServerForPath(directoryPath: String, completionHandler: (Void) -> Void) {
        guard PrototypeController.webServer == nil else {
            completionHandler()
            return
        }
        
        self.completionHandler = completionHandler
        
        GCDWebServer.setLogLevel(3)

        PrototypeController.webServer = GCDWebServer()
        PrototypeController.webServer.delegate = self
        PrototypeController.webServer.addGETHandlerForBasePath("/", directoryPath: directoryPath, indexFilename: "index.html", cacheAge: 0, allowRangeRequests: true)
        PrototypeController.webServer.startWithPort(8080, bonjourName: "Bonjour")
    }
    
    private func prototypePathInDirectory(directoryPath: String) -> String! {
        let contents = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(directoryPath)
        guard let filenames = contents else { return nil }
        
        for filename in filenames where NSNumberFormatter().numberFromString(filename) != nil {
            return "http://localhost:8080/\(filename)/marvelapp.com/index.html"
        }
        
        return nil
    }
}

// MARK: - GCDWebServerDelegate

extension PrototypeController: GCDWebServerDelegate {
    public func webServerDidStart(server: GCDWebServer!) {
        self.completionHandler?()
    }
}