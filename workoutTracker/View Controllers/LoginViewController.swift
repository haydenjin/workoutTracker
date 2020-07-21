//
//  LoginViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-20.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

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
    }
    

}
