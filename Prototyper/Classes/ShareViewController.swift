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
    
    static let ExplanationTextViewPlaceholder = "Notes"

    fileprivate var emailTextField: UITextField!
    fileprivate var explanationTextView: UITextView!
    fileprivate var seperatorLine: UIView!
    
    fileprivate var bottomSpaceConstraint: NSLayoutConstraint!
    fileprivate var annotationViewController: UIViewController?

    fileprivate var wasFeedbackButtonHidden = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Share app"
        self.wasFeedbackButtonHidden = PrototypeController.sharedInstance.isFeedbackButtonHidden
        PrototypeController.sharedInstance.isFeedbackButtonHidden = true

        view.backgroundColor = UIColor.white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(ShareViewController.cancelButtonPressed(_:)))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendButtonPressed(_:)))
        
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
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.font = UIFont.systemFont(ofSize: 17)
        view.addSubview(emailTextField)
        
        let metrics = ["textFieldHeight": 30, "sideSpacing": 12, "topSpacing": 8]
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
        
        let metrics = ["sideSpacing": 0, "verticalSpacing": 3, "lineHeight": 1.0/UIScreen.main.scale]
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
        explanationTextView.font = UIFont.systemFont(ofSize: 17)
        explanationTextView.text = ShareViewController.ExplanationTextViewPlaceholder
        explanationTextView.textColor = UIColor.lightGray
        explanationTextView.delegate = self
        view.addSubview(explanationTextView)
        
        let metrics = ["sideSpacing": 7, "topSpacing": 8]
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
        PrototypeController.sharedInstance.isFeedbackButtonHidden = wasFeedbackButtonHidden
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    func sendButtonPressed(_ sender: AnyObject) {
        guard let email = emailTextField.text else {
            self.showNoEmailAlert()
            return
        }
        
        guard !email.isEmpty else {
            self.showNoEmailAlert()
            return
        }
        
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
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        guard NSPredicate(format:"SELF MATCHES %@", emailRegEx).evaluate(with: emailTextField.text ?? "") else {
            print("Invalid email address")
            self.showNoEmailAlert()
            return
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        let explanationText = explanationTextView.text == ShareViewController.ExplanationTextViewPlaceholder ? "" : explanationTextView.text!
        
        APIHandler.sharedAPIHandler.sendShareRequest(for: emailTextField.text ?? "", because: explanationText, name: name, success: {
            print("Successfully sent share request to server")
            PrototypeController.sharedInstance.isFeedbackButtonHidden = self.wasFeedbackButtonHidden
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }) { (error) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.showErrorAlert()
        }
    }

    
    // MARK: Helper
    
    fileprivate func showErrorAlert() {
        let alertController = UIAlertController(title: Texts.ShareErrorActionSheet.Title, message: Texts.ShareErrorActionSheet.Message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: Texts.ShareErrorActionSheet.OK, style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func showNoEmailAlert() {
        let alertController = UIAlertController(title: Texts.ShareNoEmailActionSheet.Title, message: Texts.ShareNoEmailActionSheet.Message, preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: Texts.ShareNoEmailActionSheet.OK, style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }

    fileprivate func showLoginView() {
        let instantiatedViewController = UIStoryboard(name: "Login", bundle: Bundle(for: LoginViewController.self)).instantiateInitialViewController()
        guard let navController = instantiatedViewController as? UINavigationController, let loginViewController = navController.topViewController as? LoginViewController else { return }
        loginViewController.delegate = self
        self.present(navController, animated: true, completion: nil)
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

// MARK: - LoginViewControllerDelegate

extension ShareViewController: LoginViewControllerDelgate {
    func userLoggedIn() {
        self.sendFeedback()
    }
}
