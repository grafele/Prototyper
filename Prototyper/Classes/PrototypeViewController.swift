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
    
    public var enableForceTouchToFeedback: Bool = true {
        didSet {
            addTouchRecognizer()
        }
    }
    
    private var prototypeView: PrototypeView!
    private var touchRecognizer: UIGestureRecognizer!
    private var currentlyPresenting: Bool = false
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        createPrototypeView()
        prototypeView.prototypeAddress = prototypeAddress
        prototypeView.loadContent()
        
        addTouchRecognizer()
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
    
    private func addTouchRecognizer() {
        defer { touchRecognizer.enabled = enableForceTouchToFeedback }
        guard touchRecognizer == nil else { return }
        
        if #available(iOS 9.0, *) {
            if self.view.traitCollection.forceTouchCapability == .Available {
                let deepPressGestureRecognizer = DeepPressGestureRecognizer(target: self, action: #selector(showFeedbackView), threshold: 0.8)
                deepPressGestureRecognizer.vibrateOnDeepPress = true
                deepPressGestureRecognizer.delegate = self
                touchRecognizer = deepPressGestureRecognizer
                
                self.view.addGestureRecognizer(deepPressGestureRecognizer)
                return
            }
        }
        
        touchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showFeedbackView))
        touchRecognizer.delegate = self
        self.view.addGestureRecognizer(touchRecognizer)
    }
    
    // MARK: Actions
    
    public func showFeedbackView() {
        guard presentingViewController == nil else { return }
        guard !currentlyPresenting else { return }
        
        currentlyPresenting = true
        
        let feedbackViewController = FeedbackViewController()
        
        let screenshot = UIApplication.sharedApplication().keyWindow?.snaphot()
        feedbackViewController.screenshot = screenshot
        
        let navigationController = UINavigationController(rootViewController: feedbackViewController)
        self.presentViewController(navigationController, animated: true) {
            self.currentlyPresenting = false
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PrototypeViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}