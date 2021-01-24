//
//  Constants.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-21.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Storyboard {
        
        // Constant for the home view
        static let homeViewController = "HomeVC"
        
        static let rootViewController = "RootVC"
    }
}

class StructVariables {
    
    // Master Exercises Array
    static var masterExercises = Exercises()
    
    // Variable for passing along name of workout
    static var nameOfWorkout = String()
    
    // Used to keep track of looping number of sets in order to update data
    static var count2 = 0
    
    // Used to keep track of looping number of sets for Exercises VC
    static var counter = 0
}
