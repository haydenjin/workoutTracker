//
//  RootViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-20.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpElements()
    }
    
    func setUpElements() {

        // Styling the elements
        Utilities.styleFilledButton(signUpButton)
        Utilities.styleHollowButton(loginButton)
    }

}
