//
//  FeedbackViewController.swift
//  Prototype
//
//  Created by Stefan Kofler on 13.06.15.
//  Copyright (c) 2015 Stephan Rabanser. All rights reserved.
//

import UIKit
import KeychainSwift

class FeedbackViewController: UIViewController {
    
    static let ImageAnnotationControllerSegueIdentifier = "showAnnotationScreen"
    static let DescriptionTextViewPlaceholder = "Add some description here..."
    
    var screenshot: UIImage?
    var url: NSURL?
    
    private var titleTextField: UITextField!
    private var descriptionTextView: UITextView!
    private var seperatorLine: UIView!
    
    private var bottomSpaceConstraint: NSLayoutConstraint!
    private var annotationViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Feedback"
        
        view.backgroundColor = UIColor.whiteColor()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: #selector(FeedbackViewController.cancelButtonPressed(_:)))
        
        let sendButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: #selector(FeedbackViewController.sendButtonPressed(_:)))
        let imageButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: #selector(FeedbackViewController.imageButtonPressed(_:)))
        
        self.navigationItem.rightBarButtonItems = [sendButton, imageButton]
        
        registerNotifcationObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addTitleTextField()
        addSeperatorLine()
        addDescriptionTextView()
    }
    
    private func addTitleTextField() {
        guard titleTextField == nil else { return }
        
        titleTextField = UITextField()
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleTextField.placeholder = "Title"
        titleTextField.font = UIFont.systemFontOfSize(14)
        view.addSubview(titleTextField)
        
        let metrics = ["textFieldHeight": 30, "sideSpacing": 8, "topSpacing": 2]
        let views: [String: AnyObject] = ["titleTextField": titleTextField, "topGuide": topLayoutGuide]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-sideSpacing-[titleTextField]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-topSpacing-[titleTextField(textFieldHeight)]", options: [], metrics: metrics, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    private func addSeperatorLine() {
        guard seperatorLine == nil else { return }
        
        seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor.blackColor()
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperatorLine)
        
        let metrics = ["sideSpacing": 0, "verticalSpacing": 0, "lineHeight": 1.0/UIScreen.mainScreen().scale]
        let views: [String: AnyObject] = ["titleTextField": titleTextField, "seperatorLine": seperatorLine]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-sideSpacing-[seperatorLine]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[titleTextField]-verticalSpacing-[seperatorLine(lineHeight)]", options: [], metrics: metrics, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    private func addDescriptionTextView() {
        guard descriptionTextView == nil else { return }
        
        descriptionTextView = UITextView()
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.textContainerInset = UIEdgeInsetsZero
        descriptionTextView.contentInset = UIEdgeInsetsZero
        descriptionTextView.font = UIFont.systemFontOfSize(14)
        descriptionTextView.text = FeedbackViewController.DescriptionTextViewPlaceholder
        descriptionTextView.textColor = UIColor.lightGrayColor()
        descriptionTextView.delegate = self
        view.addSubview(descriptionTextView)
        
        let metrics = ["sideSpacing": 3, "topSpacing": 5]
        let views: [String: AnyObject] = ["descriptionTextView": descriptionTextView, "seperatorLine": seperatorLine]
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-sideSpacing-[descriptionTextView]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[seperatorLine]-topSpacing-[descriptionTextView]", options: [], metrics: metrics, views: views)
        bottomSpaceConstraint = NSLayoutConstraint(item: view, attribute: .Bottom, relatedBy: .Equal, toItem: descriptionTextView, attribute: .Bottom, multiplier: 1, constant: 0)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        view.addConstraint(bottomSpaceConstraint)
    }
    
    // MARK: Observers
    
    func registerNotifcationObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: Keyboard Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboardInfo = notification.userInfo as! [String: AnyObject]
        let keyboardFrame = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue
        let animationDuration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        UIView.animateWithDuration(animationDuration!, animations: { () -> Void in
            if let height = keyboardFrame?.size.height {
                self.bottomSpaceConstraint.constant = height + 5
            }
            
            self.view.layoutIfNeeded()
        })
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let keyboardInfo = notification.userInfo as! [String: AnyObject]
        let animationDuration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        UIView.animateWithDuration(animationDuration!, animations: { () -> Void in
            self.bottomSpaceConstraint.constant = 0
            
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Actions
        
    func cancelButtonPressed(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func sendButtonPressed(sender: AnyObject) {
        guard APIHandler.sharedAPIHandler.isLoggedIn else  {
            print("You need to make sure you are logged in.")
            
            let keychain = KeychainSwift()
            let oldUsername = keychain.get(LoginViewController.UsernameKey)
            let oldPassword = keychain.get(LoginViewController.PasswordKey)
            
            if let oldUsername = oldUsername, let oldPassword = oldPassword {
                APIHandler.sharedAPIHandler.login(oldUsername, password: oldPassword, success: {
                    self.sendButtonPressed(self)
                }) { (error) in
                    self.showLoginView()
                }
            } else {
                showLoginView()
            }
            
            
            return
        }
        
        guard let screenshot = screenshot else {
            print("You need a screenshot set to send screen feedback")
            return
        }
        
        self.navigationItem.rightBarButtonItem?.enabled = false
        
        let descriptionText = descriptionTextView.text == FeedbackViewController.DescriptionTextViewPlaceholder ? "" : descriptionTextView.text

        APIHandler.sharedAPIHandler.sendScreenFeedback(titleTextField.text ?? "", screenshot: screenshot, description: descriptionText, success: {
            print("Successfully sent feedback to server")
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }) { (error) in
            self.navigationItem.rightBarButtonItem?.enabled = true
            self.showErrorAlert()
        }
    }
    
    func imageButtonPressed(sender: AnyObject) {
        let annotationViewController = ImageAnnotationViewController()
        annotationViewController.image = screenshot
        annotationViewController.delegate = self
        
        let navController = UINavigationController(rootViewController: annotationViewController)
        self.presentViewController(navController, animated: true, completion: nil)
    }
    
    // MARK: Helper
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Could not send feedback to server!", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func showLoginView() {
        let loginViewController = UIStoryboard(name: "Login", bundle: NSBundle(forClass: LoginViewController.self)).instantiateInitialViewController()!
        self.presentViewController(loginViewController, animated: true, completion: nil)
    }
    
}

extension FeedbackViewController: ImageAnnotationViewControllerDelegate {
    func imageAnnotated(image: UIImage) {
        self.screenshot = image
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == FeedbackViewController.DescriptionTextViewPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = FeedbackViewController.DescriptionTextViewPlaceholder
            textView.textColor = UIColor.lightGrayColor()
            textView.resignFirstResponder()
        }
    }
}
