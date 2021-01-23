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
    
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "ExerciseCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    // Variable to hold name for Workout (Dont need it for this VC)
    var workoutName = ""
    
    // Variable to receive name from
    var exerciseName = ""
    
    // Variable exercise for passed in exercise
    var exercise = Exercises.VariableExercises()
    
    var doneTapped = false
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        nameOfExercise.text = exerciseName
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Reset the count
        StructVariables.count = 0
    }
    
    
    // MARK: - Sending data to database
    
    @IBAction func DoneButtonTapped(_ sender: Any) {
        
        doneTapped = true
        
        tableView.reloadData()
        
        // Reset the count
        StructVariables.count2 = 0
    }
    
    // MARK: - Tableview Functions
    
    // Returns the number of sections (# of sets)
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.exercise.totalSets
    }
    
    // Returns 1 as we only want one row per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Sets the cell spacing height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Makes the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Picking what cell displays this data
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ExerciseTableViewCell
        
        // Configure cell with data with the object in each array slot
        //let exercise = self.exercise
        
        // Setting the style of the cell
        Utilities.styleTableViewCells(cell)
        
        
        // If button was tapped, send data stamped info back to database
        if doneTapped == true {
            
            // Getting new input from text fields
            cell.getNewInfo(exercise)
            
            // If statement so loop only runs once (Limits reads and writes to database)
            if StructVariables.count2 == exercise.totalSets {
                
                // Get a reference to the database
                let db = Firestore.firestore()
                
                // Get current user ID
                let userId = Auth.auth().currentUser!.uid
                
                // Adds the array of exercises to the database
                let workout = db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutName)
                
                // Getting the current date
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let date = df.string(from: Date())
                
                workout.collection("WorkoutExercises").document(exerciseName).setData(["Message": "Default"])
                
                for count in 0...exercise.totalSets-1 {
                    //workout.collection("WorkoutExercises").document(exerciseName).collection(date).document(exerciseName).setData(["Reps\(count+1)": exercise.reps[count], "Weight\(count+1)": exercise.weights[count]], merge: true)
                }
            }
        }
        // Button wasn't tapped, set up tableview cells like usual
        else {
            cell.setCell(exercise)
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
    
    // MARK: - Pulling from database
    
    func getData() {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Get current user ID
        let userId = Auth.auth().currentUser!.uid
        
        // Getting the data to show workouts
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").document(workoutName).collection("WorkoutExercises").document(exerciseName).getDocument { (document, error) in
            if let document = document, document.exists {
                
                let exercise = Exercises.VariableExercises()
                exercise.name = self.exerciseName
                
                let data:[String:Any] = document.data()!
                
                exercise.notes = data["Notes"] as! String
                // Need to do this since it is listed as a String in the database so using as! Int crashes the program
                exercise.totalSets = Int(data["numberofsets"] as! String)!
                
                for number in 0...(exercise.totalSets - 1) {
                    
                    exercise.sets.append(Sets())
                    
                    // Jumping over this line somehow, try to rap tableview.reloaddata in a function and force get data to run first
                    
                    // Retrives the reps
                    let repsDbCall = Firestore.firestore().collection("users").document("\(userId)").collection("Workouts").document(self.workoutName).collection("WorkoutExercises").document(self.exerciseName).collection("Set\(number + 1)").document("reps")
                    
                    repsDbCall.getDocument { (document, error) in
                        if let document = document, document.exists {
                            // For every document (Set) in the database, copy the values and add them to the array
                            
                            let data:[String:Any] = document.data()!
                            
                            exercise.sets[number].reps = data["Reps\(number + 1)"] as! Int
                            //exercise.sets[number].weights = 155//Int(data["weights"] as! String)!
                        }
                        else {
                            // There was an error, display it somehow
                        }
                    }
                    
                    //Retrives the weights
                }
                self.exercise = exercise
            }
            // Reloading the data so it can be displayed
            self.tableView.reloadData()
        }
    }
}
