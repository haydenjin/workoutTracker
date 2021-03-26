//
//  NewWorkouts.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import Foundation

// File containing exercises for an individual workout

class Workouts {
    
    var name = ""
    var exercises = [Exercises]()
    
}

// Used to check if all exercises in an workout has been completed
class WorkoutChecker {
    
    var name = ""
    var done = false
    
    func addNewRecord(name:String, done:Bool) {
        self.name = name
        self.done = done
    }
    
}

class LastPerformed {
    
    var name = ""
    var lastPerformed = "--"
    
    func addNewRecord(name:String, lastPerformed:String) {
        self.name = name
        self.lastPerformed = lastPerformed
    }
    
}
