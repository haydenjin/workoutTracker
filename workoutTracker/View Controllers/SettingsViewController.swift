//
//  SecondViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Purchases

class SettingsViewController: UIViewController {

    @IBOutlet weak var getProButton: UIButton!
    
    @IBAction func signOutTapped(_ sender: Any) {
        // Logs user out
        
        Master.workouts.removeAll()
        Master.exercises.removeAll()
        
        StructVariables.getDataCalled = false
        
        AppManager.shared.logout()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        // Listen for function turned pro
        NotificationCenter.default.addObserver(self, selector: #selector(showProContent), name: NSNotification.Name("turned pro"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Check if the user has premium
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive == true {
                
                self.showProContent()
            }
        }
    }
    
    @objc func showProContent() {
        self.getProButton.setTitle("You are a pro member already!!!", for: .normal)
    }
}
