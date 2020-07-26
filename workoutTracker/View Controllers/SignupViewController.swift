//
//  SignupViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-20.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

// Note: the database is currently not secure, make sure to change it after

class SignupViewController: UIViewController {

    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    func setUpElements() {
        
        // Hiding the error label
        errorLabel.alpha = 0
        
        // Styling the elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextfield)
        Utilities.styleFilledButton(signUpButton)
    }
    
    // Check the fields and see if the data is correct, if everything is good, it returns nil, or else it returns an error message in the form of a string
    func validateFields() -> String? {
        
        // Check that all fields are filled while removing white spaces and new lines
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextfield.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields"
        }
        
        // Check if the password is secure
        let cleanedPasswork = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPasswork) == false {
            return "Password isn't secure enough, please make sure your password has at least (One character)(One uppercase character)(One special character) and (Is at least 6 characters long)"
        }
        
        // Check if email is valid
        
        return nil
    }
    
    // Function to output error messages
        func showError(_ message:String) {
        
        // Change the error label and make it visible
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    

    
        // Button in root view controller that sends you to the login page
        @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            // There was an error
            showError(error!)
        }
        else {
            
            // Create cleaned versions of data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextfield.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    // There was an error creating the user
                    self.showError("Error creating user")
                }
                else {
                    // User was created successfully, now store the first and last name
                    let db = Firestore.firestore()
                    
                    // Adding the user's name and user id to the database
                    db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid":result!.user.uid]) { (error) in
                        
                        if error != nil {
                            self.showError("User data couldn't be added to database")
                        }
                    }
                
                    // Move to the home screen
                    self.transitionToHome()
                }
            }
        }
    }
    
    func transitionToHome() {
        
        // setting the variable as the home view
        let homeViewController = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.homeViewController) as? UITabBarController
        
        // Setting the user view as the homeVC
        view.window?.rootViewController = homeViewController
        // Setting the current view and making it visible 
        view.window?.makeKeyAndVisible()
    }
    
}
