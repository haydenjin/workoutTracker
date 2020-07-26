//
//  UserAddedExercises.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-18.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import Foundation
import UIKit

// This class will contain all user added excercises
class UserAddedExercises {
    
    var name = ""
    var notes = ""
    var sets = 0
    var reps = 0
    var weights = 0

    // Adds a new exercise to be used
    func addExercises(name:String, notes:String, weight:Int, reps:Int, sets:Int) {
        self.name = name
        self.notes = notes
        self.weights = weight
        self.reps = reps
        self.sets = sets
    }
}
