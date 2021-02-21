//
//  EditExerciseViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-02-21.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class EditExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var nameOfExercise: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "ExerciseCell"
    
    // Variable to hold name for Workout (Dont need it for this VC)
    var workoutName = ""
    
    // Variable to receive name from
    var exerciseName = ""
    
    // Tracks if the user hit the done button
    var doneTapped = false
    
    // Holds the most recent workout logged (DATE)
    var mostRecent = ""
    
    var workoutIndex = 0
    
    var exerciseIndex = 0
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData(workoutName: workoutName, exerciseName: exerciseName)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        nameOfExercise.text = exerciseName
        
        // Makes lines that separate tableView cells invisible
        self.tableView.separatorColor = UIColor .clear
        
    }
    
    // MARK: - Sending data to database
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        doneTapped = true
        
        tableView.reloadData()
        
        // Reset the count
        StructVariables.count2 = 0
    }
    
    // MARK: - Tableview Functions
    
    // Returns the number of cells that we want
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Master.workouts[workoutIndex].exercises[exerciseIndex].sets.count
    }
    
    // Makes the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Picking what cell displays this data
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as! ExerciseTableViewCell
        
        
        // Setting the style of the cell
        Utilities.styleTableViewCells(cell)
        
        // MARK: - Saving data to Database
        
        // If button was tapped, send data stamped info back to database
        if doneTapped == true {
            
            // Getting new input from text fields
            cell.getNewInfo(Master.workouts[workoutIndex].exercises[exerciseIndex])
            
            // If statement so loop only runs once (Limits reads and writes to database)
            if StructVariables.count2 == Master.workouts[workoutIndex].exercises[exerciseIndex].sets.count {
                
                // Adds the array of exercises to the database
                let workout = db.collection("users").document("\(userId)").collection("Workouts").document(workoutName)
                
                let WorkoutExercises = workout.collection("WorkoutExercises")
                
                // Loop for each exercise
                for num in 0...(Master.workouts[workoutIndex].exercises.count - 1) {
                    
                    // Name of individual exercise
                    let workout = WorkoutExercises.document("\(Master.workouts[workoutIndex].exercises[num].name)")
                    
                    // Adding the note
                    workout.setData(["Notes": String(Master.workouts[workoutIndex].exercises[num].notes)], merge: true)
                    
                    // Add the count for number of reps
                    workout.setData(["numberofsets": String(Master.workouts[workoutIndex].exercises[num].sets.count)], merge: true)
                    
                    // Add a random order for now
                    workout.setData(["Order": 0], merge: true)
                    
                    // Loop for sets for each exercise
                    for set in 1...Master.workouts[workoutIndex].exercises[num].sets.count {
                        workout.collection("Set" + String(set)).document("reps").setData(["Reps\(set)": Master.workouts[workoutIndex].exercises[num].sets[set - 1].reps], merge: true)
                        
                        workout.collection("Set" + String(set)).document("weights").setData(["Weight\(set)": Master.workouts[workoutIndex].exercises[num].sets[set - 1].weights], merge: true)
                    }
                }
                // Transitioning the screen back to edit screen
                performSegue(withIdentifier: "backToEdit", sender: self)
            }
        }
        // Button wasn't tapped, set up tableview cells like usual
        else {
            
            // Start setting the fields
            cell.setNum.text = "Set \(indexPath.row + 1)"
            cell.reps.text = "\(Master.workouts[workoutIndex].exercises[exerciseIndex].sets[indexPath.row].reps)"
            cell.weight.text = "\(Master.workouts[workoutIndex].exercises[exerciseIndex].sets[indexPath.row].weights)"
            
            cell.formatCell()
        }
        
        // Return the cell
        return cell
    }
    
    // MARK: - Sending data back to WorkoutVC
    
    // Sending data to Workout started view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Set a variable as an object of the viewcontroller we want to pass data to
        let sb = segue.destination as! EditWorkoutViewController
        
        sb.workoutNameCopy = workoutName
        
    }
    
    
    
    // MARK: - Get data from Master array
    func getData(workoutName: String, exerciseName: String) {
        
        // Gets the proper workout
        for i in 0...Master.workouts.count - 1 {
            if Master.workouts[i].name == workoutName {
                self.workoutIndex = i
            }
        }
        
        // Gets the proper exercise
        for i in 0...Master.workouts[workoutIndex].exercises.count - 1 {
            if Master.workouts[workoutIndex].exercises[i].name == exerciseName {
                self.exerciseIndex = i
            }
        }
    }
    
    // Add another set
    @IBAction func addSet(_ sender: Any) {
    }
    
    // delete the selected set
    @IBAction func deleteSet(_ sender: Any) {
    }
    
}
