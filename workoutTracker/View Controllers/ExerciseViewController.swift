//
//  ExerciseViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-08-11.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class ExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
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
    
    // Variable exercise for passed in exercise
    //var exercise = Exercises.VariableExercises()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        
    }
    
    
    // MARK: - Sending data to database
    
    @IBAction func DoneButtonTapped(_ sender: Any) {
        
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
                let workout = db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutName)
                
                workout.setData(["Set": "Not virtual"])
                
                // Getting the current date
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let date = df.string(from: Date())
                
                workout.collection(exerciseName).document(date).setData(["Set": "Not virtual"], merge: true)
                
                workout.collection(exerciseName).document(date).setData(["Date": date], merge: true)
                
                
                for count in 0...Master.workouts[workoutIndex].exercises[exerciseIndex].sets.count-1 {
                    
                    // Saves reps
                    workout.collection(exerciseName).document(date).collection("Set\(count + 1)").document("reps").setData(["Reps\(count+1)": Master.workouts[workoutIndex].exercises[exerciseIndex].sets[count].reps], merge: true)
                    
                    // Saves weights
                    workout.collection(exerciseName).document(date).collection("Set\(count + 1)").document("weights").setData(["Weight\(count+1)": Master.workouts[workoutIndex].exercises[exerciseIndex].sets[count].weights], merge: true)
                }
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
        let sb = segue.destination as! WorkoutStartedViewController
        
        sb.workoutName = workoutName
        
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
}
