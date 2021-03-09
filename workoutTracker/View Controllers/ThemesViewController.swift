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

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func blackMint(_ sender: Any) {
        
        var body: some View {
            Color.black.overlay(VStack(spacing: 20) {
            }).edgesIgnoringSafeArea(.vertical)
        }
        
        print("turn black")

    }
    
    @IBAction func tealWhite(_ sender: Any) {
        
        var body: some View {
            Color.white.overlay(VStack(spacing: 20) {
            }).edgesIgnoringSafeArea(.vertical)
        }
        
        print("turn white")
    }
}
