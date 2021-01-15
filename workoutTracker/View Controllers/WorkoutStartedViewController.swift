//
//  WorkoutStartedViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-29.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class WorkoutStartedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var nameOfWorkout: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "ActiveWorkoutCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    var workoutName = ""
    
    // Array holding all exercises for a workout
    var exercisesArray = [Exercises]()
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        // Name is passed in by HomeViewController
        nameOfWorkout.text = workoutName
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    // MARK: - Tableview Functions
    
    // Returns the number of sections (# of workouts)
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.exercisesArray.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ActiveWorkoutTableViewCell
        
        // Configure cell with data with the object in each array slot
        let exercise = self.exercisesArray[indexPath.section]
        
        // Setting the style of the cell
        Utilities.styleTableViewCells(cell)
        
        cell.setCell(exercise)
        
        // Return the cell
        return cell
    }
    
    // MARK: - Completing workout
    
    // Sends data of finished workout back to database
    @IBAction func completeWorkoutTapped(_ sender: Any) {
        
        for workout in exercisesArray {
            print(workout.name)
            print(workout.sets)
            for num in 0...workout.sets.count{
                print(workout.sets[num].reps)
                print(workout.sets[num].weights)
            }
            
        }
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Get current user ID
        let userId = Auth.auth().currentUser!.uid
        
        // Setting the name of the workout
        let name = nameOfWorkout.text
        
        tableView.reloadData()
        
        // For loop to add every exercise
        for count in 0...(exercisesArray.count - 1) {
            
            // Adds the array of exercises to the database with a date stamp
            let workoutData = db.collection("users").document("\(userId)").collection("WorkoutData").document(name!)
            
            for _ in 0...(exercisesArray.count - 1) {
                workoutData.setData(["Date": FieldValue.serverTimestamp()])
                
                //Creates todays date
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                // Path (users/uid/workouts/Exercises/NameofExercise/data)
                workoutData.collection("\(exercisesArray[count].name)").document(formatter.string(from: Date()))
                
                for num in 0...exercisesArray[count - 1].sets.count {
                    
                    workoutData.collection("Set" + String(num)).document("reps").setData(["Reps": exercisesArray[count].sets[num].reps], merge: true)
                    
                    workoutData.collection("Set" + String(num)).document("weights").setData(["Weight": exercisesArray[count].sets[num].weights], merge: true)
                }
            }
        }
        
        // MARK: - Field Formating functions
        
        // Function to formate the text fields
        func formatTextField(_ textField:UITextField) {
            
            // Create a variable
            let textfield = textField
            
            // Make itself the delegate
            textfield.delegate = self
            
            // Set the return as (done)
            textfield.returnKeyType = .done
            
            // Auto caps the first letter of each sentence
            textfield.autocapitalizationType = .sentences
            
            // Center the screen on the text field when clicked
            textfield.center = self.view.center
            
        }
        
        // Function to drop down text field after its done being used
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
        // MARK: - Pulling from database
        
        func getData() {
            
            // Get a reference to the database
            let db = Firestore.firestore()
            
            // Get current user ID
            let userId = Auth.auth().currentUser!.uid
            
            // Getting the data to show workouts
            // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
            db.collection("users").document("\(userId)").collection("Workouts").document(workoutName).collection("WorkoutExercises").getDocuments { (snapshot, error) in
                
                if error != nil {
                }
                else {
                    // For every document (exercise) in the database, copy the values and add them to the array
                    for document in snapshot!.documents {
                        
                        // Setting all the fields for each exercise
                        let exercise = Exercises()
                        exercise.name = document.documentID
                        let data:[String:Any] = document.data()
                        
                        var note = ""
                        
                        if (data["Notes"] != nil) {
                            note = data["Notes"] as! String
                        }
                        
                        exercise.notes = note
                        
                        let numberOfSets = data["Number of sets"] as! Int
                        // Loop for reps
                        for set in 1...numberOfSets {
                            exercise.sets[set].reps = data["reps \(set)"] as! Int
                            exercise.sets[set].weights = data["weights \(set)"] as! Int
                        }
                        self.exercisesArray.append(exercise)
                        
                        // Reloading the data so it can be displayed
                        self.tableView.reloadData()
                    }
                }
            }
            
            // MARK: - Sending data to ExerciseVC
            
            // Sending data to Workout started view
            func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                
                // Check that a workout was tapped
                guard tableView.indexPathForSelectedRow != nil else {
                    return
                }
                
                // Get the workout that was tapped
                let selectedExercise = exercisesArray[tableView.indexPathForSelectedRow!.section]
                
                // Set a variable as an object of the viewcontroller we want to pass data to
                let sb = segue.destination as! ExerciseViewController
                
                sb.workoutName = workoutName
                
                // Setting data to pass over
                sb.exerciseName = selectedExercise.name
            }
        }
    }
}
