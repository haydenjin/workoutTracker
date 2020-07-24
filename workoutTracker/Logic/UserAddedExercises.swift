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
    
    @IBOutlet weak var nameOfExercise: UITextField!
    @IBOutlet weak var additionalNotes: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var reps: UITextField!
    
    // Checks if all required fields are filled out
    func validateFields() -> String? {
    
    // Check that all fields are filled while removing white spaces and new lines
    if nameOfExercise.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        weight.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
        reps.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
        
        // Fields not filled, Display error message
        return "Please fill in all fields"
        }
        // Fields are filled, keep going
        return nil
    }
    
    // Adds a new exercise to be used
    func addExercises() {
        
        

    }
}
