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
    var totalSets = 0
    var sets = [Sets]()
    
    func addNewExercise(name:String, notes:String, weight:Int, reps:Int, sets:Int) {
        self.name = name
        self.notes = notes
        
        for _ in 0..<sets {
            let newSet = Sets()
            newSet.reps = reps
            newSet.weights = weight
            
            self.sets.append(newSet)
        }
    }
}
