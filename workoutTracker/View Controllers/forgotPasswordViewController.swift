//
//  forgotPasswordViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-03-23.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class forgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func resetPassword(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: "email@email") { error in
            // Your code here
        }
    }
}
