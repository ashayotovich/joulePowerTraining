//
//  ViewController.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 4/5/22.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    let db = Firestore.firestore()
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var boxesHeight: NSLayoutConstraint!
    @IBOutlet weak var boxesSpacer: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            print(navigationController.viewControllers.count)
        }
        
        usernameTextField.font = UIFont(name: "Helvetica Neue", size: view.frame.width * 0.04)
        passwordTextField.font = UIFont(name: "Helvetica Neue", size: view.frame.width * 0.04)
        loginButton.titleLabel?.font = UIFont(name: "Helvetica Neue", size: view.frame.width * 0.04)
        
        boxesSpacer.constant = view.frame.width / 8
        boxesHeight.constant = view.frame.width * 0.667 / 5
        
        usernameTextField.text = privateVariables.loginUser
        passwordTextField.text = privateVariables.loginPassword
        
        self.passwordTextField.delegate = self
        usernameTextField.hideSuggestions()
        passwordTextField.hideSuggestions()
        passwordTextField.returnKeyType = UIReturnKeyType.go
        
        usernameTextField.layer.cornerRadius = (view.frame.width - 2 * boxesSpacer.constant) / 10
        passwordTextField.layer.cornerRadius = (view.frame.width - 2 * boxesSpacer.constant) / 10
        loginButton.layer.cornerRadius = (view.frame.width - 2 * boxesSpacer.constant) / 10
        
        usernameTextField.layer.shadowOpacity = 1
        usernameTextField.layer.shadowRadius = 5.0
        usernameTextField.layer.shadowOffset = CGSize.zero
        usernameTextField.layer.shadowColor = UIColor.black.cgColor
        
        passwordTextField.layer.shadowOpacity = 1
        passwordTextField.layer.shadowRadius = 5.0
        passwordTextField.layer.shadowOffset = CGSize.zero
        passwordTextField.layer.shadowColor = UIColor.black.cgColor
        
        loginButton.layer.shadowOpacity = 1
        loginButton.layer.shadowRadius = 5.0
        loginButton.layer.shadowOffset = CGSize.zero
        loginButton.layer.shadowColor = UIColor.black.cgColor
        
        self.navigationController?.isToolbarHidden = true
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        passwordTextField.resignFirstResponder()
        loginPressed(loginButton)
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WorkoutSetupViewController
        
        let email = usernameTextField.text
        destinationVC.currentUserEmail = email!

    }

    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = usernameTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: K.segues.loginToSetup, sender: self)
                }
            }
        }
    }
    
//    @IBAction func loginPressed(_ sender: UIButton) {
//        if let email = usernameTextField.text, let password = passwordTextField.text {
//            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//                if let e = error {
//                    print(e.localizedDescription)
//                } else {
//                    self.performSegue(withIdentifier: "testingSummary", sender: self)
//                }
//            }
//        }
//    }
}


//MARK: - Extensions used for manipulating keyboard settings

extension UITextView {
    func hideSuggestions() {
        // Removes suggestions only
        autocorrectionType = .no
        //Removes Undo, Redo, Copy & Paste options
        removeUndoRedoOptions()
    }
}

extension UITextField {
    func hideSuggestions() {
        // Removes suggestions only
        autocorrectionType = .no
        //Removes Undo, Redo, Copy & Paste options
        removeUndoRedoOptions()
    }
}

extension UIResponder {
    func removeUndoRedoOptions() {
        //Removes Undo, Redo, Copy & Paste options
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
    }
}




