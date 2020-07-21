//
//  SignupViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-20.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

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
    
    // Button in root view controller that sends you to the login page
    @IBAction func signUpTapped(_ sender: Any) {
    }
    
}
