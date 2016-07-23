//
//  LoginViewController.swift
//  Pods
//
//  Created by Stefan Kofler on 21.07.16.
//
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        
        addBarButtonItems()
        configureLoginButton()
        addObservers()
    }
    
    private func addBarButtonItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(cancelButtonPressed))
    }
    
    private func configureLoginButton() {
        loginButton.layer.cornerRadius = 8.0
        loginButton.enabled = false
    }
    
    private func addObservers() {
        emailField.addTarget(self, action: #selector(validateTextFields), forControlEvents: .EditingChanged)
        passwordField.addTarget(self, action: #selector(validateTextFields), forControlEvents: .EditingChanged)
    }
    
    // MARK: Actions
    
    func cancelButtonPressed() {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func validateTextFields() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        loginButton.enabled = !email.isEmpty && !password.isEmpty
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""

        APIHandler.sharedAPIHandler.login(email, password: password, success: {
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        }) { (error) in
            self.showErrorAlert()
        }
    }
    
    // MARK: Helper
    
    private func showErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Could not log in! Please check your login credentials and try again.", preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}