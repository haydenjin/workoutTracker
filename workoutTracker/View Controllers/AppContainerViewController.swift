//
//  AppContainerViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class AppContainerViewController: UIViewController {

    // Everytime this screen shows up, see if the user if already logged in and show the appropriate screen
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AppManager.shared.appContainer = self
        AppManager.shared.showApp()
        
    }
}
