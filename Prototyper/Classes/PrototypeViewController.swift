//
//  PrototypeViewController.swift
//  PrototypeFrameWork
//
//  Created by Stefan Kofler on 28.05.16.
//  Copyright © 2016 Stefan Kofler. All rights reserved.
//

import UIKit

public class PrototypeViewController: UIViewController {
    
    public var prototypeAddress: String = "" {
        didSet {
            guard prototypeView != nil else { return }
            prototypeView.prototypeAddress = prototypeAddress
            prototypeView.loadContent()
        }
    }
    
    private var prototypeView: PrototypeView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        createPrototypeView()
        prototypeView.prototypeAddress = prototypeAddress
        prototypeView.loadContent()
        
        // TODO: Remove
        showFeedbackController()
    }
    
    public func loadPrototypePage(pageId: String) {
        PrototypeController.sharedInstance.prototypePathForPageId(pageId) { (prototypePath) in
            self.prototypeAddress = prototypePath
        }
    }
    
    private func createPrototypeView() {
        prototypeView = PrototypeView(frame: self.view.bounds)
        prototypeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(prototypeView)
        
        let topConstaint = NSLayoutConstraint(item: prototypeView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstaint = NSLayoutConstraint(item: prototypeView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: prototypeView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: prototypeView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1, constant: 0)
        
        self.view.addConstraints([topConstaint, bottomConstaint, leftConstraint, rightConstraint])
    }
    
    private func showFeedbackController() {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            let feedbackViewController = FeedbackViewController()
            
            let screenshot = UIApplication.sharedApplication().keyWindow?.snaphot()
            feedbackViewController.screenshot = screenshot
            
            let navigationController = UINavigationController(rootViewController: feedbackViewController)
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
}