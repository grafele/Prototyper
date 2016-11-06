//
//  PrototypeViewController.swift
//  PrototypeFrameWork
//
//  Created by Stefan Kofler on 28.05.16.
//  Copyright © 2016 Stefan Kofler. All rights reserved.
//

import UIKit

open class PrototypeViewController: UIViewController {
    
    open var prototypeAddress: String = "" {
        didSet {
            guard prototypeView != nil else { return }
            prototypeView.prototypeAddress = prototypeAddress
            prototypeView.loadContent()
        }
    }
    
    open var enableFeedback: Bool = true {
        didSet {
            addTouchRecognizer()
        }
    }
    
    fileprivate var prototypeView: PrototypeView!
    fileprivate var touchRecognizer: UIGestureRecognizer!
    fileprivate var currentlyPresenting: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        
        createPrototypeView()
        prototypeView.prototypeAddress = prototypeAddress
        prototypeView.loadContent()
        
        addTouchRecognizer()
    }
    
    open func loadPrototypePage(_ pageId: String) {
        PrototypeController.sharedInstance.prototypePathForPageId(pageId) { (prototypePath) in
            self.prototypeAddress = prototypePath
        }
    }
    
    fileprivate func createPrototypeView() {
        prototypeView = PrototypeView(frame: self.view.bounds)
        prototypeView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(prototypeView)
        
        let topConstaint = NSLayoutConstraint(item: prototypeView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let bottomConstaint = NSLayoutConstraint(item: prototypeView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: prototypeView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: prototypeView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        
        self.view.addConstraints([topConstaint, bottomConstaint, leftConstraint, rightConstraint])
    }
    
    fileprivate func addTouchRecognizer() {
        print("add touch recognizer")
        
        touchRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showFeedbackView))
        touchRecognizer.delegate = self
        self.view.addGestureRecognizer(touchRecognizer)
    }
    
    // MARK: Actions
    
    open func showFeedbackView() {
        print("show feedback view")

        guard presentingViewController == nil else { return }
        guard !currentlyPresenting else { return }
        
        currentlyPresenting = true
        
        let feedbackViewController = FeedbackViewController()
        PrototypeController.sharedInstance.isFeedbackButtonHidden = true

        let screenshot = UIApplication.shared.keyWindow?.snaphot()
        feedbackViewController.screenshot = screenshot
        
        let navigationController = UINavigationController(rootViewController: feedbackViewController)
        self.present(navigationController, animated: true) {
            self.currentlyPresenting = false
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension PrototypeViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
