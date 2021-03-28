//
//  ThemesViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-03-01.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import SwiftUI

class ThemesViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        overrideUserInterfaceStyle = .light
    }
    
    
    @IBAction func blackMint(_ sender: Any) {
        
        Utilities.Themes.blackMint()
        
        print("turn black")

    }
    
    @IBAction func tealWhite(_ sender: Any) {
        
        Utilities.Themes.tealWhite()
        
        print("turn white")
    }
    
    @IBAction func teal(_ sender: Any) {
        
        Utilities.Themes.teal()
        
        print("turn blue")
    }
}
