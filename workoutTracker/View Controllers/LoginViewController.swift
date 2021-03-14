//
//  LoginViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-20.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    func setUpElements() {
        
        // Hiding the error label
        errorLabel.alpha = 0
        
        // Styling the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
        
    }
    
    // Button in root view controller that sends you to the signin page
    @IBAction func loginTapped(_ sender: Any) {
        
        // Validate Text fields
        
        // Create cleaned data
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Sign in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                
                StructVariables.comingFromLogin = true
                
                // setting the variable as the home view
                let homeViewController = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? UITabBarController
                
                // Setting the user view as the homeVC
                self.view.window?.rootViewController = homeViewController
                // Setting the current view and making it visible
                self.view.window?.makeKeyAndVisible()
            }
        }
    }
}
