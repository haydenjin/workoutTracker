//
//  AddWorkoutViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class AddWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    // Variable that references the array of exercises
    var copyWorkoutExercises:Array = Array<Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Variable needed to retreve the exercises from another class
        let copiedWorkoutExercises: UserAddedExercisesArray = UserAddedExercisesArray()
        // Setting our variable equal to the array of exercises
        copyWorkoutExercises = copiedWorkoutExercises.workoutExercisesArray
        
        print("Items before append \(copyWorkoutExercises.count)")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the number of exercises we have
        print(copyWorkoutExercises.count)
        return copyWorkoutExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    // Picking what cell displays this data
    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutExercisesCell", for: indexPath) as! WorkoutExercisesTableViewCell
    
    // Configure cell with data with the object in each array slot
    let exercise = self.copyWorkoutExercises[indexPath.row]
    
    cell.setCell(exercise as! Exercises)
    
    // Return the cell
    return cell
    }
    
}
