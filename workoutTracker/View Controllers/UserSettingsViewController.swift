//
//  UserSettingsViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-04-24.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class UserSettingsViewController: UIViewController {
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var userName: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        Utilities.addDoneButtonOnKeyboard((userName))

        db.collection("users").document("\(userId)").getDocument { (document, error) in
            if let document = document, document.exists {
                
                let data:[String:Any] = document.data()!
                
                self.userName.text = "\(data["firstname"] as! String)"
                
            }
        }
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
        if userName.text != " " {
            
            // Gets rid of spaces
            let realText = userName.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Saves new username
            db.collection("users").document("\(userId)").setData(["firstname": realText])
            
            // Dismisses the text field
            userName.resignFirstResponder()
            
            self.dismiss(animated: true) {
                
            }
        }
    }
}
