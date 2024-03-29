//
//  Constants.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-21.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import Foundation
import SwiftUI

struct Constants {
    
    struct Storyboard {
        
        // Constant for the home view
        static let homeViewController = "HomeVC"
        
        static let rootViewController = "RootVC"
    }
}

class Master {
    
    // Master array of workouts, filled in with a query at run time and passed around to different screens
    static var workouts = [Workouts]()
    
    // Master Exercises Array
    static var exercises = [Exercises]()
    
    // Checks which exercises are done at what point
    static var workoutCheck = [WorkoutChecker]()
    
    // Stores the last time a workout was performed
    static var lastPerformed = [LastPerformed]()
}

class StructVariables {
    
    // Variable for passing along name of workout
    static var nameOfWorkout = String()
    
    // Used to keep track of looping number of sets in order to update data
    static var count2 = 0
    
    // Checks if user is coming from loggin screen
    static var comingFromLogin = false
    
    // Used so get data is only called once
    static var getDataCalled = false
    
    // Used to keep track of number of workouts
    static var numberOfWorkouts = 0
}
