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
    fileprivate var deleteScreenshotButton: UIButton!
    
    fileprivate var bottomSpaceConstraint: NSLayoutConstraint!
    fileprivate var annotationViewController: UIViewController?
    
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    var wasFeedbackButtonHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Feedback"
        self.automaticallyAdjustsScrollViewInsets = false
        
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
        
        let annotationOverlay = UIImageView(image: UIImage(named: "annotation_overlay", in: Bundle(for: FeedbackViewController.self), compatibleWith: nil))
        annotationOverlay.translatesAutoresizingMaskIntoConstraints = false
        screenshotButton.addSubview(annotationOverlay)
        
        let annotationOverlaySize: CGFloat = 60
        
        let widthConstraint = NSLayoutConstraint(item: annotationOverlay, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: annotationOverlaySize)
        let heightConstraint = NSLayoutConstraint(item: annotationOverlay, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: annotationOverlaySize)
        let centerXConstraint = NSLayoutConstraint(item: annotationOverlay, attribute: .centerX, relatedBy: .equal, toItem: screenshotButton, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: annotationOverlay, attribute: .centerY, relatedBy: .equal, toItem: screenshotButton, attribute: .centerY, multiplier: 1, constant: 0)
        
        screenshotButton.addConstraints([widthConstraint, heightConstraint, centerXConstraint, centerYConstraint])
        
        let deleteButtonSize: CGFloat = 25
        
        let deleteButton = UIButton(type: .custom)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setBackgroundImage(UIImage(named: "delete_icon", in: Bundle(for: FeedbackViewController.self), compatibleWith: nil), for: .normal)

        deleteButton.addTarget(self, action: #selector(deleteScreenshotButtonPressed(_:)), for: .touchUpInside)
        view.addSubview(deleteButton)
        deleteScreenshotButton = deleteButton

        let deleteButtonMetrics = ["inset": -17, "size": deleteButtonSize]
        let deleteButtonViews = ["screenshotButton": screenshotButton!, "deleteButton": deleteButton]
        
        let horizontalButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[deleteButton(size)]-inset-[screenshotButton]", options: [], metrics: deleteButtonMetrics, views: deleteButtonViews)
        let verticalButtonConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[deleteButton(size)]-inset-[screenshotButton]", options: [], metrics: deleteButtonMetrics, views: deleteButtonViews)
        
        view.addConstraints(horizontalButtonConstraints)
        view.addConstraints(verticalButtonConstraints)
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
                self.showLoginView()
            }))
            alertController.addAction(UIAlertAction(title: Texts.LoginAlertSheet.No, style: .default, handler: { _ in
                self.askForNameAndSendFeedback()
            }))
            self.present(alertController, animated: true, completion: nil)
        } else {
            sendFeedback()
        }
    }
    
    func deleteScreenshotButtonPressed(_ sender: Any) {
        screenshot = nil
        screenshotButton.isHidden = true
        deleteScreenshotButton?.isHidden = true
        descriptionTextView.textContainer.exclusionPaths = []
        
        self.navigationItem.rightBarButtonItem?.isEnabled = descriptionTextView.text != FeedbackViewController.DescriptionTextViewPlaceholder
    }
    
    private func askForNameAndSendFeedback() {
        let alertController = UIAlertController(title: Texts.StateYourNameAlertSheet.Title, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = Texts.StateYourNameAlertSheet.Placeholder
            textField.text = UserDefaults.standard.string(forKey: UserDefaultKeys.Username)
        }
        alertController.addAction(UIAlertAction(title: Texts.StateYourNameAlertSheet.Send, style: .default, handler: { _ in
            let name = alertController.textFields?.first?.text ?? ""
            UserDefaults.standard.set(name, forKey: UserDefaultKeys.Username)
            self.sendFeedback(name: name)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func sendFeedback(name: String? = nil) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let descriptionText = descriptionTextView.text == FeedbackViewController.DescriptionTextViewPlaceholder ? "" : descriptionTextView.text
        
        showAcitivityIndicator()
        
        if let screenshot = screenshot {
            APIHandler.sharedAPIHandler.sendScreenFeedback(screenshot: screenshot, description: descriptionText!, name: name, success: {
                self.feedbackSendingSuccesfull()
            }) { (error) in
                self.feedbackSendingFailed()
            }
        } else {
            APIHandler.sharedAPIHandler.sendGeneralFeedback(description: descriptionText!, name: name, success: {
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
        let instantiatedViewController = UIStoryboard(name: "Login", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController()
        guard let navController = instantiatedViewController as? UINavigationController, let loginViewController = navController.topViewController as? LoginViewController else { return }
        loginViewController.delegate = self
        self.present(navController, animated: true, completion: nil)
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
        
        let extraHeight = max(0, textView.contentSize.height - textView.bounds.size.height)
        let imgRect = UIBezierPath(rect: CGRect(x: self.view.bounds.size.width - (125+15), y: 0, width: 125+10, height: 221 + extraHeight))
        descriptionTextView.textContainer.exclusionPaths = screenshot == nil ? [] : [imgRect]
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 2000
    }
}

// MARK: - LoginViewControllerDelegate

extension FeedbackViewController: LoginViewControllerDelgate {
    func userLoggedIn() {
        self.sendFeedback()
    }
}
