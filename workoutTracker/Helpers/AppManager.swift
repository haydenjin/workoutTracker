//
//  AppManager.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AppManager {
    
    static let shared = AppManager()
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    var appContainer: AppContainerViewController!
    
    private init() {}
    
    func showApp() {
        var viewController: UIViewController
        
        // Checks if a user has already logged in on this device
        if Auth.auth().currentUser == nil {
            
            // No user is logged in, show the login / sign up view
            viewController = storyboard.instantiateViewController(withIdentifier: "RootVC")
        }
        else {
            // User is signed in, show home screen
            viewController = storyboard.instantiateViewController(withIdentifier: "HomeVC")
        }
        
        // Makes the screen fullscreen instead of a pop up
        viewController.modalPresentationStyle = .fullScreen
        appContainer.present(viewController, animated: true, completion: nil)
    }
    
    func logout() {
        
        try! Auth.auth().signOut()
        
        //appContainer.presentedViewController?.dismiss(animated: true, completion: nil)
    }
}
