//
//  AddWorkoutViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class AddWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Array holding all exercises for a workout
    var exerciseArrayCopy = [Exercises]()
    
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // Gets the data from the Popup screen
    @IBAction func unwindToAddExercise(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? PopupViewController {
            
            // Copying the data from the other viewcontroller and combining (Merging) the arrays
            exerciseArrayCopy += sourceViewController.exerciseArray
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reloading the data so it can be displayed
        tableView.reloadData()
    }
    
    // MARK: - TableView Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Returns the number of exercises we have
        return exerciseArrayCopy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    // Picking what cell displays this data
    let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutExercisesCell", for: indexPath) as! WorkoutExercisesTableViewCell
    
    // Configure cell with data with the object in each array slot
    let exercise = self.exerciseArrayCopy[indexPath.row]
    
    cell.setCell(exercise)
    
    // Return the cell
    return cell
    }
}
