//
//  ShareViewController.swift
//  Prototype
//
//  Created by Stefan Kofler on 13.06.15.
//  Copyright (c) 2015 Stephan Rabanser. All rights reserved.
//

import UIKit
import KeychainSwift

class ShareViewController: UIViewController {
    
    static let ExplanationTextViewPlaceholder = "Explain us why we should add this user."

    fileprivate var emailTextField: UITextField!
    fileprivate var explanationTextView: UITextView!
    fileprivate var seperatorLine: UIView!
    
    fileprivate var bottomSpaceConstraint: NSLayoutConstraint!
    fileprivate var annotationViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Share app"
        
        view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(ShareViewController.cancelButtonPressed(_:)))
        
        let sendButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.compose, target: self, action: #selector(ShareViewController.sendButtonPressed(_:)))
        
        self.navigationItem.rightBarButtonItem = sendButton
        
        registerNotifcationObserver()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        addEmailTextField()
        addSeperatorLine()
        addExplanationTextView()
    }
    
    fileprivate func addEmailTextField() {
        guard emailTextField == nil else { return }
        
        emailTextField = UITextField()
        emailTextField.translatesAutoresizingMaskIntoConstraints = false
        emailTextField.placeholder = "Share with (E-Mail)"
        emailTextField.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(emailTextField)
        
        let metrics = ["textFieldHeight": 30, "sideSpacing": 8, "topSpacing": 2]
        let views: [String: AnyObject] = ["emailTextField": emailTextField, "topGuide": topLayoutGuide]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-sideSpacing-[emailTextField]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[topGuide]-topSpacing-[emailTextField(textFieldHeight)]", options: [], metrics: metrics, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    fileprivate func addSeperatorLine() {
        guard seperatorLine == nil else { return }
        
        seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor.black
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(seperatorLine)
        
        let metrics = ["sideSpacing": 0, "verticalSpacing": 0, "lineHeight": 1.0/UIScreen.main.scale]
        let views: [String: AnyObject] = ["emailTextField": emailTextField, "seperatorLine": seperatorLine]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-sideSpacing-[seperatorLine]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[emailTextField]-verticalSpacing-[seperatorLine(lineHeight)]", options: [], metrics: metrics, views: views)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
    }
    
    fileprivate func addExplanationTextView() {
        guard explanationTextView == nil else { return }
        
        explanationTextView = UITextView()
        explanationTextView.translatesAutoresizingMaskIntoConstraints = false
        explanationTextView.textContainerInset = UIEdgeInsets.zero
        explanationTextView.contentInset = UIEdgeInsets.zero
        explanationTextView.font = UIFont.systemFont(ofSize: 14)
        explanationTextView.text = ShareViewController.ExplanationTextViewPlaceholder
        explanationTextView.textColor = UIColor.lightGray
        explanationTextView.delegate = self
        view.addSubview(explanationTextView)
        
        let metrics = ["sideSpacing": 3, "topSpacing": 5]
        let views: [String: AnyObject] = ["explanationTextView": explanationTextView, "seperatorLine": seperatorLine]
        
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "|-sideSpacing-[explanationTextView]-sideSpacing-|", options: [], metrics: metrics, views: views)
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[seperatorLine]-topSpacing-[explanationTextView]", options: [], metrics: metrics, views: views)
        bottomSpaceConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: explanationTextView, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints(horizontalConstraints)
        view.addConstraints(verticalConstraints)
        view.addConstraint(bottomSpaceConstraint)
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
                self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let explanationText = explanationTextView.text == ShareViewController.ExplanationTextViewPlaceholder ? "" : explanationTextView.text!
        
        APIHandler.sharedAPIHandler.sendShareRequest(for: emailTextField.text ?? "", because: explanationText, success: {
            print("Successfully sent share request to server")
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.showErrorAlert()
        }
    }
    
    // MARK: Helper
    
    fileprivate func showErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Could not send share request to server!", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func showLoginView() {
        let loginViewController = UIStoryboard(name: "Login", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController()!
        self.present(loginViewController, animated: true, completion: nil)
    }
    
}

extension ShareViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == ShareViewController.ExplanationTextViewPlaceholder {
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = ShareViewController.ExplanationTextViewPlaceholder
            textView.textColor = UIColor.lightGray
            textView.resignFirstResponder()
        }
    }
}