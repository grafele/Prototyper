//
//  LoginViewController.swift
//  Pods
//
//  Created by Stefan Kofler on 21.07.16.
//
//

import UIKit
import KeychainSwift

protocol LoginViewControllerDelgate: class {
    func userLoggedIn()
}

class LoginViewController: UIViewController {
    
    static let UsernameKey = "UsernameKey"
    static let PasswordKey = "PasswordKey"
    
    @IBOutlet fileprivate weak var descriptionLabel: UILabel!
    @IBOutlet fileprivate weak var emailField: UITextField!
    @IBOutlet fileprivate weak var passwordField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    weak var delegate: LoginViewControllerDelgate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Login"
        
        addBarButtonItems()
        configureLoginButton()
        addObservers()
    }
    
    fileprivate func addBarButtonItems() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonPressed))
    }
    
    fileprivate func configureLoginButton() {
        loginButton.layer.cornerRadius = 8.0
        loginButton.isEnabled = false
    }
    
    fileprivate func addObservers() {
        emailField.addTarget(self, action: #selector(validateTextFields), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(validateTextFields), for: .editingChanged)
    }
    
    // MARK: Actions
    
    func cancelButtonPressed() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func validateTextFields() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        loginButton.isEnabled = !email.isEmpty && !password.isEmpty
    }
    
    @IBAction func loginButtonPressed(_ sender: AnyObject) {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""

        APIHandler.sharedAPIHandler.login(email, password: password, success: {
            let keychain = KeychainSwift()
            keychain.set(email, forKey: LoginViewController.UsernameKey)
            keychain.set(password, forKey: LoginViewController.PasswordKey)

            self.presentingViewController?.dismiss(animated: true, completion: nil)
            self.delegate?.userLoggedIn()
        }) { (error) in
            self.showErrorAlert()
        }
    }
    
    // MARK: Helper
    
    fileprivate func showErrorAlert() {
        let alertController = UIAlertController(title: "Error", message: "Could not log in! Please check your login credentials and try again.", preferredStyle: UIAlertControllerStyle.alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
