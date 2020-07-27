//
//  Exercises.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import Foundation
import UIKit

// This class will contain all exercises

class Exercises {
    
    var name = ""
    var notes = ""
    var weights = 0
    var reps = 0
    var sets = 0
    
    func addNewExercise(name:String, notes:String, weight:Int, reps:Int, sets:Int) {
        self.name = name
        self.notes = notes
        self.weights = weight
        self.reps = reps
        self.sets = sets
    }
}
