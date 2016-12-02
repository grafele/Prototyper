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
import KeychainSwift

open class PrototypeController: NSObject {
    open static let sharedInstance = PrototypeController()
    fileprivate static var webServer: GCDWebServer!
    fileprivate static var containerMap = [String: String]()
    
    fileprivate static let PrototypeControllerMD5HashKey = "PrototypeControllerMD5HashKey"
    
    fileprivate var completionHandler: ((Void) -> Void)?
    
    fileprivate var feedbackBubble: FeedbackBubble!
    
    open var shouldShowFeedbackButton: Bool = true {
        didSet {
            if shouldShowFeedbackButton {
                isFeedbackButtonHidden = false
                addFeedbackButton()
                tryToFetchReleaseInfos()
            } else {
                isFeedbackButtonHidden = true
            }
        }
    }
    
    var isFeedbackButtonHidden: Bool = false {
        didSet {
            if isFeedbackButtonHidden {
                feedbackBubble?.isHidden = true
            } else {
                feedbackBubble?.isHidden = false
            }
        }
    }
    
    open func preloadPrototypes(_ containers: [String]? = ["container"], _ completionHandler: ((Void) -> Void)? = nil) {
        let containers = containers ?? ["container"]
        
        tryToFetchReleaseInfos()
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        deleteOldContainers(in: documentsPath)
        
        for containerFile in containers {
            if let containerPath = Bundle.main.path(forResource: containerFile, ofType: "zip") {
                PrototypeController.containerMap[containerFile] = unzipContainerIfNecessary(containerPath, destination: documentsPath, container: containerFile)
            }
        }
        
        startWebServerForPath(documentsPath) {
            completionHandler?()
        }
    }
    
    open func prototypePathForContainer(_ container: String) -> String {
        if let filename = PrototypeController.containerMap[container] {
            return "http://localhost:8080/\(filename)/marvelapp.com/index.html"
        }
        
        return ""
    }
    
    fileprivate func unzipContainerIfNecessary(_ containerPath: String, destination: String, container: String) -> String? {
        guard let _ = FileManager.default.contents(atPath: containerPath) else { return nil }
        
        try? SSZipArchive.unzipFile(atPath: containerPath, toDestination: destination, overwrite: false, password: nil)
        
        let contents = try? FileManager.default.contentsOfDirectory(atPath: destination)
        guard let filenames = contents else { return nil }
        
        for filename in filenames where PrototypeController.containerMap[container] == nil {
            if isPrototypeFolder(filename) {
                return filename
            }
        }
        
        return nil
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
    
    fileprivate func deleteOldContainers(in directoryPath: String) {
        let contents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath)
        guard let filenames = contents else { return }
        
        for filename in filenames where isPrototypeFolder(filename) {
            try? FileManager.default.removeItem(atPath: directoryPath.appending("/\(filename)"))
        }
    }
    
    @available(*, deprecated)
    open func prototypePathForPageId(_ pageId: String, completionHandler: @escaping (_ prototypePath: String) -> Void) {
        print("This method is deprecated. Use prototypePathForContainer instead")
    }
    
    @available(*, deprecated)
    fileprivate func prototypePathInDirectory(_ directoryPath: String) -> String? {
        let contents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath)
        guard let filenames = contents else { return nil }
        
        for filename in filenames where isPrototypeFolder(filename) {
            return "http://localhost:8080/\(filename)/marvelapp.com/index.html"
        }
        
        return nil
    }
    
    // MARK: Feedback
    
    func feedbackBubbleTouched() {
        let actionSheet = UIAlertController(title: Texts.FeedbackActionSheet.Title, message: Texts.FeedbackActionSheet.Text, preferredStyle: .actionSheet)
        actionSheet.popoverPresentationController?.sourceView = feedbackBubble
        actionSheet.popoverPresentationController?.sourceRect = feedbackBubble.bounds
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
        if let rootViewController = getTopViewController() {
            rootViewController.present(actionSheet, animated: true, completion: nil)
        }
    }
    
    private func addFeedbackButton() {
        let keyWindow = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first
        feedbackBubble = feedbackBubble == nil ? FeedbackBubble(target: self, action: #selector(feedbackBubbleTouched)) : feedbackBubble
        feedbackBubble.layer.zPosition = 100
        keyWindow?.addSubview(feedbackBubble)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            keyWindow?.addSubview(self.feedbackBubble)
        }
    }
    
    private func showFeedbackView() {
        guard let rootViewController = getTopViewController() else { return }
        
        let feedbackViewController = FeedbackViewController()
        feedbackViewController.wasFeedbackButtonHidden = PrototypeController.sharedInstance.isFeedbackButtonHidden
        PrototypeController.sharedInstance.isFeedbackButtonHidden = true
        
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
            
            self.showInfoAlertAfterHiding()
        }
    }
    
    private func shareApp() {
        guard let rootViewController = getTopViewController() else { return }
        
        let shareViewController = ShareViewController()
        
        let navigationController = UINavigationController(rootViewController: shareViewController)
        rootViewController.present(navigationController, animated: true, completion: nil)
    }
    
    private func showInfoAlertAfterHiding() {
        guard let rootViewController = getTopViewController() else { return }
        
        let alertController = UIAlertController(title: Texts.FeedbackHideAlertSheet.Title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Texts.FeedbackHideAlertSheet.OK, style: .default, handler: nil))
        rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Helpers
    
    private func tryToFetchReleaseInfos() {
        APIHandler.sharedAPIHandler.fetchReleaseInformation(success: { (appId, releaseId) in
            UserDefaults.standard.set(appId, forKey: UserDefaultKeys.AppId)
            UserDefaults.standard.set(releaseId, forKey: UserDefaultKeys.ReleaseId)
        }) { error in
            print("No release information found on Prototyper.")
        }
    }
    
    private func tryToLogin() {
        let keychain = KeychainSwift()
        let oldUsername = keychain.get(LoginViewController.UsernameKey)
        let oldPassword = keychain.get(LoginViewController.PasswordKey)
        
        if let oldUsername = oldUsername, let oldPassword = oldPassword {
            APIHandler.sharedAPIHandler.login(oldUsername, password: oldPassword, success: {}, failure: { _ in })
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else { return nil }
        
        var currentVC = rootViewController
        
        while let presentedVC = currentVC.presentedViewController {
            currentVC = presentedVC
        }
        
        return currentVC
    }
    
    private func isPrototypeFolder(_ filename: String) -> Bool {
        return NumberFormatter().number(from: filename) != nil || filename.range(of: "c_") != nil
    }
}

// MARK: - GCDWebServerDelegate

extension PrototypeController: GCDWebServerDelegate {
    public func webServerDidStart(_ server: GCDWebServer!) {
        self.completionHandler?()
    }
}
