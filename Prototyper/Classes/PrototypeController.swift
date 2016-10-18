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
    
    fileprivate var feedbackBubble: FeedbackBubble!
    
    open var shouldShowFeedbackButton: Bool =  true {
        didSet {
            if shouldShowFeedbackButton {
                feedbackBubble?.isHidden = false
                addFeedbackButton()
            } else {
                feedbackBubble?.isHidden = true
            }
        }
    }
    
    open func preloadPrototypes(_ completionHandler: ((Void) -> Void)?) {
        let containerPath = Bundle.main.path(forResource: "container", ofType: "zip")!
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        unzipContainerIfNecessary(containerPath, documentsPath: documentsPath)
        startWebServerForPath(documentsPath) {
            completionHandler?()
        }
        
        APIHandler.sharedAPIHandler.fetchReleaseInformation(success: { (appId, releaseId) in
            UserDefaults.standard.set(appId, forKey: UserDefaultKeys.AppId)
            UserDefaults.standard.set(releaseId, forKey: UserDefaultKeys.ReleaseId)
        }) { error in
            print("Error fetching release information: \(error)")
        }
    }
    
    open func prototypePathForPageId(_ pageId: String, completionHandler: @escaping (_ prototypePath: String) -> Void) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        preloadPrototypes {
            completionHandler("\(self.prototypePathInDirectory(documentsPath) ?? "")?exp=1#\(pageId)")
        }
    }
    
    fileprivate func unzipContainerIfNecessary(_ containerPath: String, documentsPath: String) {
        guard let data = FileManager.default.contents(atPath: containerPath) else { return }
        
        let md5String = ((data as NSData).md5() as NSData).description
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
    
    // MARK: Feedback
    
    func feedbackBubbleTouched() {
        let actionSheet = UIAlertController(title: Texts.FeedbackActionSheet.Title, message: Texts.FeedbackActionSheet.Text, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: Texts.FeedbackActionSheet.WriteFeedback, style: .default) { _ in
            self.showFeedbackView()
        })
        actionSheet.addAction(UIAlertAction(title: Texts.FeedbackActionSheet.ShareApp, style: .default) { _ in
            self.shareApp()
        })
        actionSheet.addAction(UIAlertAction(title: Texts.FeedbackActionSheet.HideFeedbackBubble, style: .default) { _ in
            self.hideFeedbackButton()
        })
        actionSheet.addAction(UIAlertAction(title: Texts.FeedbackActionSheet.Cancel, style: .cancel, handler: nil))
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func addFeedbackButton() {
        guard self.feedbackBubble == nil else { return }
        
        let keyWindow = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        feedbackBubble = FeedbackBubble(target: self, action: #selector(feedbackBubbleTouched))
        feedbackBubble.layer.zPosition = 100
        keyWindow?.addSubview(feedbackBubble)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            keyWindow?.addSubview(self.feedbackBubble)
        }
    }
    
    private func showFeedbackView() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        
        let feedbackViewController = FeedbackViewController()
        
        let screenshot = UIApplication.shared.keyWindow?.snaphot()
        feedbackViewController.screenshot = screenshot
        
        let navigationController = UINavigationController(rootViewController: feedbackViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
    }
    
    private func hideFeedbackButton() {
        UIView.animate(withDuration: 0.3, animations: { 
            self.feedbackBubble?.alpha = 0.0
        }) { _ in
            self.shouldShowFeedbackButton = false
            self.feedbackBubble?.alpha = 1.0
        }
    }
    
    private func shareApp() {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return }
        
        let shareViewController = ShareViewController()
                
        let navigationController = UINavigationController(rootViewController: shareViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - GCDWebServerDelegate

extension PrototypeController: GCDWebServerDelegate {
    public func webServerDidStart(_ server: GCDWebServer!) {
        self.completionHandler?()
    }
}
