//
//  Exercises.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import Foundation

// This class will contain all common exercises for quick addition to workouts
// User added workouts will be stored in a separate file

class Exercises {
    
    var name = ""
    var notes = ""
    var weight:Int = 0
    var reps:Int = 0
    var sets:Int = 0
    
    func addNewExercise(name:String, notes:String, weight:Int, reps:Int, sets:Int) {
        self.name = name
        self.notes = notes
        self.weight = weight
        self.reps = reps
        self.sets = sets
    }
    
    func addNewEmptyExercise(name:String, notes:String) {
        self.name = name
        self.notes = notes
    }
}
