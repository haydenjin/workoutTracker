//
//  SecondViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBAction func signOutTapped(_ sender: Any) {
        // Logs user out
        AppManager.shared.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}
