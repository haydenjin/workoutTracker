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
    
    @IBAction func themesButton(_ sender: Any) {
        
        // Check if the user has premium
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            
            if purchaserInfo?.entitlements.all["pro"]?.isActive != true {
                
                // Moves to pro view controller
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
                
            } else {
                
                // Moves to themes view controller
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "themes") as! ThemesViewController
                newViewController.modalPresentationStyle = .fullScreen
                self.present(newViewController, animated: true, completion: nil)
                return
            }
        }
    }
}
