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
        
        formatLoginScreen()
        
        usernameTextField.text = privateVariables.loginUser
        passwordTextField.text = privateVariables.loginPassword
        
    }
    
    func formatLoginScreen() {
        resizeViews()
        formatTextFieldElements(viewElement: self.usernameTextField)
        formatTextFieldElements(viewElement: self.passwordTextField)
        formatButtonelements(viewElement: self.loginButton)
        self.navigationController?.isToolbarHidden = true
    }
    
    func resizeViews() {
        self.boxesSpacer.constant = view.frame.width / 8
        self.boxesHeight.constant = view.frame.width * 0.667 / 5
    }
    
    func formatTextFieldElements(viewElement: UITextField) {
        viewElement.layer.shadowOpacity = 1
        viewElement.layer.shadowRadius = 5.0
        viewElement.layer.shadowOffset = CGSize.zero
        viewElement.layer.shadowColor = UIColor.black.cgColor
        
        viewElement.layer.cornerRadius = (self.view.frame.width - 2 * self.boxesSpacer.constant) / 10
        
        viewElement.font = UIFont(name: "Helvetica Neue", size: view.frame.width * 0.04)
        
        viewElement.hideSuggestions()
        
        if viewElement == self.passwordTextField {
            viewElement.delegate = self
            viewElement.returnKeyType = UIReturnKeyType.go
        }
        
    }
    
    func formatButtonelements(viewElement: UIButton) {
        viewElement.layer.shadowOpacity = 1
        viewElement.layer.shadowRadius = 5.0
        viewElement.layer.shadowOffset = CGSize.zero
        viewElement.layer.shadowColor = UIColor.black.cgColor
        
        viewElement.layer.cornerRadius = (self.view.frame.width - 2 * self.boxesSpacer.constant) / 10
        
        viewElement.titleLabel?.font = UIFont(name: "Helvetica Neue", size: view.frame.width * 0.04)
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
}


//MARK: - Extensions used for manipulating keyboard settings

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




