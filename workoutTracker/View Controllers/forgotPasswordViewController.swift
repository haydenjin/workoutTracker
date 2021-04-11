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

        overrideUserInterfaceStyle = .light
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        
        if email.text != "" {
            Auth.auth().sendPasswordReset(withEmail: email.text!) { error in
                if error == nil {
                    // Worked
                    self.view.endEditing(true)
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "RootVC") as! RootViewController
                    nextViewController.modalPresentationStyle = .fullScreen
                    self.present(nextViewController, animated:true, completion:nil)
                    
                } else {
                    // Didn't work
                    
                }
            }
        }
    }
}
