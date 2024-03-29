//
//  AppDelegate.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds
import Purchases

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var firstLoad = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Init firebase
        FirebaseApp.configure()
        
        Purchases.debugLogsEnabled = true
        Purchases.configure(withAPIKey: "QfEEhSTeVfHgvKBCNkckGfYppkiqaYsT")
        
        // Init AdMob
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        firstLoad = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
