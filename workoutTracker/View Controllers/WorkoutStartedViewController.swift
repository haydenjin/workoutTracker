//
//  WorkoutStartedViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-29.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class WorkoutStartedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nameOfWorkout: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var name = ""
    
    // Array holding all exercises for a workout
    var exercisesArray = [Exercises]()
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameOfWorkout.text = name
    }
    
    // MARK: - Tableview Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercisesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Picking what cell displays this data
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActiveWorkoutCell", for: indexPath) as! ActiveWorkoutTableViewCell
        
        // Configure cell with data with the object in each array slot
        let exercise = self.exercisesArray[indexPath.row]
        
        cell.setCell(exercise)
        
        // Return the cell
        return cell
    }
    
    // MARK: - Logic
    
    // Sends data of finished workout back to database
    @IBAction func completeWorkoutTapped(_ sender: Any) {
    }
    

}
