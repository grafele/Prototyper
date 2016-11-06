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
    fileprivate var screenshotButton: UIButton!
    
    fileprivate var bottomSpaceConstraint: NSLayoutConstraint!
    fileprivate var annotationViewController: UIViewController?
    
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    fileprivate var wasFeedbackButtonHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Feedback"
        self.automaticallyAdjustsScrollViewInsets = false
        self.wasFeedbackButtonHidden = PrototypeController.sharedInstance.isFeedbackButtonHidden
        
        view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(FeedbackViewController.cancelButtonPressed(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendButtonPressed(_:)))
        
        registerNotifcationObserver()
        addActivityIndicator()
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
        descriptionTextView.font = UIFont.systemFont(ofSize: 17)
        descriptionTextView.text = FeedbackViewController.DescriptionTextViewPlaceholder
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self
        view.addSubview(descriptionTextView)
        
        let imgRect = UIBezierPath(rect: CGRect(x: self.view.bounds.size.width - (125+15), y: 0, width: 125+10, height: 221))
        descriptionTextView.textContainer.exclusionPaths = [imgRect]
        
        let metrics = ["sideSpacing": 6, "topSpacing": 12]
        let views: [String: AnyObject] = ["topGuide": topLayoutGuide, "descriptionTextView": descriptionTextView]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-sideSpacing-[descriptionTextView]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-topSpacing-[descriptionTextView]", options: [], metrics: metrics, views: views)
        bottomSpaceConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: descriptionTextView, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        view.addConstraint(bottomSpaceConstraint)
    }
    
    fileprivate func addScreenshotPreviewImageView() {
        guard screenshotButton == nil else { return }
        
        screenshotButton = UIButton(type: .custom)
        screenshotButton.translatesAutoresizingMaskIntoConstraints = false
        screenshotButton.setImage(screenshot, for: .normal)
        screenshotButton.layer.borderWidth = 1
        screenshotButton.layer.borderColor = UIColor(white: 0, alpha: 0.2).cgColor
        screenshotButton.addTarget(self, action: #selector(imageButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(screenshotButton)
        
        let metrics = ["sideSpacing": 10, "topSpacing": 10, "width": 125, "height": 221]
        let views: [String: AnyObject] = ["topGuide": topLayoutGuide, "screenshotButton": screenshotButton]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[screenshotButton(width)]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-topSpacing-[screenshotButton(height)]", options: [], metrics: metrics, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        
        let deleteButtonSize: CGFloat = 25
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.backgroundColor = UIColor.black
        deleteButton.tintColor = UIColor.white
        deleteButton.setTitle("x", for: .normal)
        deleteButton.layer.cornerRadius = deleteButtonSize/2.0
        deleteButton.addTarget(self, action: #selector(deleteScreenshotButtonPressed(_:)), for: .touchUpInside)
        screenshotButton.addSubview(deleteButton)
        
        let deleteButtonMetrics = ["inset": -8, "size": deleteButtonSize]
        let deleteButtonViews = ["deleteButton": deleteButton]
        
        let horizontalButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-inset-[deleteButton(size)]", options: [], metrics: deleteButtonMetrics, views: deleteButtonViews)
        let verticalButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-inset-[deleteButton(size)]", options: [], metrics: deleteButtonMetrics, views: deleteButtonViews)
        
        screenshotButton.addConstraints(horizontalButtonConstraints)
        screenshotButton.addConstraints(verticalButtonConstraints)
    }
    
    private func addActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        let leftConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: activityIndicator, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, topConstraint, rightConstraint, bottomConstraint])
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
        PrototypeController.sharedInstance.isFeedbackButtonHidden = wasFeedbackButtonHidden
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func sendButtonPressed(_ sender: AnyObject) {
        if !APIHandler.sharedAPIHandler.isLoggedIn {
            let alertController = UIAlertController(title: Texts.LoginAlertSheet.Title, message: nil, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: Texts.LoginAlertSheet.Yes, style: .default, handler: { _ in
                self.sendFeedback()
            }))
            alertController.addAction(UIAlertAction(title: Texts.LoginAlertSheet.No, style: .cancel, handler: { _ in
                self.login()
            }))
            self.present(alertController, animated: true, completion: nil)
        } else {
            sendFeedback()
        }
    }
    
    func deleteScreenshotButtonPressed(_ sender: Any) {
        screenshot = nil
        screenshotButton.isHidden = true
        descriptionTextView.textContainer.exclusionPaths = []
        
        self.navigationItem.rightBarButtonItem?.isEnabled = !descriptionTextView.text.isEmpty
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
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let descriptionText = descriptionTextView.text == FeedbackViewController.DescriptionTextViewPlaceholder ? "" : descriptionTextView.text
        
        showAcitivityIndicator()
        
        if let screenshot = screenshot {
            APIHandler.sharedAPIHandler.sendScreenFeedback(screenshot: screenshot, description: descriptionText!, success: {
                self.feedbackSendingSuccesfull()
            }) { (error) in
                self.feedbackSendingFailed()
            }
        } else {
            APIHandler.sharedAPIHandler.sendGeneralFeedback(description: descriptionText!, success: {
                self.feedbackSendingSuccesfull()
            }, failure: { (error) in
                self.feedbackSendingFailed()
            })
        }
    }
    
    private func feedbackSendingSuccesfull() {
        print("Successfully sent feedback to server")
        self.activityIndicator.stopAnimating()
        PrototypeController.sharedInstance.isFeedbackButtonHidden = self.wasFeedbackButtonHidden
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    private func feedbackSendingFailed() {
        self.activityIndicator.stopAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.showErrorAlert()
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
    
    private func showAcitivityIndicator() {
        view.bringSubview(toFront: activityIndicator)
        activityIndicator.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        activityIndicator.startAnimating()
        
        activityIndicator.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.activityIndicator.alpha = 1
        })
    }
    
}

extension FeedbackViewController: ImageAnnotationViewControllerDelegate {
    func imageAnnotated(_ image: UIImage) {
        self.screenshot = image
        screenshotButton.setImage(image, for: .normal)
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
            self.navigationItem.rightBarButtonItem?.isEnabled = screenshot != nil
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 500
    }
}
