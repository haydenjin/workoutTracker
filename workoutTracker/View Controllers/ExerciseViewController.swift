//
//  ExerciseViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-08-11.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class ExerciseViewController: UIViewController {
    
    
    @IBOutlet weak var nameOfExercise: UILabel!
    
    // Variable to hold name for Workout (Dont need it for this VC)
    var workoutName = ""
    
    // Variable to receive name from
    var exerciseName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        nameOfExercise.text = exerciseName
    }
    
    // MARK: - Sending data back to WorkoutVC
    
    // Sending data to Workout started view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set a variable as an object of the viewcontroller we want to pass data to
        let sb = segue.destination as! WorkoutStartedViewController
        
        sb.workoutName = workoutName
        
    }
    
    
}
