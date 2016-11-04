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
    static let DescriptionTextViewPlaceholder = "Add your feedback here..."
    
    var screenshot: UIImage?
    var url: URL?
    
    fileprivate var descriptionTextView: UITextView!
    fileprivate var screenshotImageView: UIImageView!
    
    fileprivate var bottomSpaceConstraint: NSLayoutConstraint!
    fileprivate var annotationViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Feedback"
        self.automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(FeedbackViewController.cancelButtonPressed(_:)))
        
        let sendButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(FeedbackViewController.sendButtonPressed(_:)))
        let imageButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(FeedbackViewController.imageButtonPressed(_:)))
        
        self.navigationItem.rightBarButtonItems = [sendButton, imageButton]
        
        registerNotifcationObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addDescriptionTextView()
        addScreenshotPreviewImageView()
    }
    
    fileprivate func addDescriptionTextView() {
        guard descriptionTextView == nil else { return }
        
        descriptionTextView = UITextView()
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.textContainerInset = UIEdgeInsets.zero
        descriptionTextView.contentInset = UIEdgeInsets.zero
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.text = FeedbackViewController.DescriptionTextViewPlaceholder
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self
        view.addSubview(descriptionTextView)
        
        let imgRect = UIBezierPath(rect: CGRect(x: self.view.bounds.size.width - (125+8), y: 0, width: 125+8, height: 221+8))
        descriptionTextView.textContainer.exclusionPaths = [imgRect]
        
        let metrics = ["sideSpacing": 3, "topSpacing": 5]
        let views: [String: AnyObject] = ["topGuide": topLayoutGuide, "descriptionTextView": descriptionTextView]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-sideSpacing-[descriptionTextView]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-topSpacing-[descriptionTextView]", options: [], metrics: metrics, views: views)
        bottomSpaceConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: descriptionTextView, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        view.addConstraint(bottomSpaceConstraint)
    }
    
    fileprivate func addScreenshotPreviewImageView() {
        guard screenshotImageView == nil else { return }
        
        screenshotImageView = UIImageView()
        screenshotImageView.translatesAutoresizingMaskIntoConstraints = false
        screenshotImageView.image = screenshot
        screenshotImageView.layer.borderWidth = 1
        screenshotImageView.layer.borderColor = UIColor.lightGray.cgColor
        view.addSubview(screenshotImageView)
        
        let metrics = ["sideSpacing": 8, "topSpacing": 8, "width": 125, "height": 221]
        let views: [String: AnyObject] = ["topGuide": topLayoutGuide, "screenshotImageView": screenshotImageView]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[screenshotImageView(width)]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-topSpacing-[screenshotImageView(height)]", options: [], metrics: metrics, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    // MARK: Observers
    
    func registerNotifcationObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Keyboard Notifications
    
    func keyboardWillShow(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo as! [String: AnyObject]
        let keyboardFrame = keyboardInfo[UIKeyboardFrameEndUserInfoKey]?.cgRectValue
        let animationDuration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        UIView.animate(withDuration: animationDuration!, animations: { () -> Void in
            if let height = keyboardFrame?.size.height {
                self.bottomSpaceConstraint.constant = height + 5
            }
            
            self.view.layoutIfNeeded()
        })
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        let keyboardInfo = (notification as NSNotification).userInfo as! [String: AnyObject]
        let animationDuration = keyboardInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        UIView.animate(withDuration: animationDuration!, animations: { () -> Void in
            self.bottomSpaceConstraint.constant = 0
            
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Actions
        
    func cancelButtonPressed(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func sendButtonPressed(_ sender: AnyObject) {
        if !APIHandler.sharedAPIHandler.isLoggedIn {
            let alertController = UIAlertController(title: Texts.LoginAlertSheet.Title, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Texts.LoginAlertSheet.Yes, style: .default, handler: { _ in
                self.login()
            }))
            alertController.addAction(UIAlertAction(title: Texts.LoginAlertSheet.No, style: .cancel, handler: { _ in
                self.sendFeedback()
            }))
            self.present(alertController, animated: true, completion: nil)
        } else {
            sendFeedback()
        }
    }
    
    private func login() {
        let keychain = KeychainSwift()
        let oldUsername = keychain.get(LoginViewController.UsernameKey)
        let oldPassword = keychain.get(LoginViewController.PasswordKey)
        
        if let oldUsername = oldUsername, let oldPassword = oldPassword {
            APIHandler.sharedAPIHandler.login(oldUsername, password: oldPassword, success: {
                self.sendFeedback()
            }) { (error) in
                self.showLoginView()
            }
        } else {
            self.showLoginView()
        }
    }
    
    private func sendFeedback() {
        guard let screenshot = screenshot else {
            print("You need a screenshot set to send screen feedback")
            return
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let descriptionText = descriptionTextView.text == FeedbackViewController.DescriptionTextViewPlaceholder ? "" : descriptionTextView.text
        
        APIHandler.sharedAPIHandler.sendScreenFeedback("", screenshot: screenshot, description: descriptionText!, success: {
            print("Successfully sent feedback to server")
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.showErrorAlert()
        }
    }
    
    func imageButtonPressed(_ sender: AnyObject) {
        let annotationViewController = ImageAnnotationViewController()
        annotationViewController.image = screenshot
        annotationViewController.delegate = self
        
        let navController = UINavigationController(rootViewController: annotationViewController)
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: Helper
    
    fileprivate func showErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Could not send feedback to server!", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showLoginView() {
        let loginViewController = UIStoryboard(name: "Login", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController()!
        self.present(loginViewController, animated: true, completion: nil)
    }
    
}

extension FeedbackViewController: ImageAnnotationViewControllerDelegate {
    func imageAnnotated(_ image: UIImage) {
        self.screenshot = image
        screenshotImageView.image = image
    }
}

extension FeedbackViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == FeedbackViewController.DescriptionTextViewPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = FeedbackViewController.DescriptionTextViewPlaceholder
            textView.textColor = UIColor.lightGray
            textView.resignFirstResponder()
        }
    }
}
