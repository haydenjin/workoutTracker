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
    
    
    var name = ""
    
    // Array holding all exercises for a workout
    var exercisesArray = [Exercises]()
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Name is passed in by HomeViewController
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
        
        formatTextField(cell.sets)
        formatTextField(cell.reps)
        formatTextField(cell.weight)
        
        // Return the cell
        return cell
    }
    
    // MARK: - Completing workout
    
    // Sends data of finished workout back to database
    @IBAction func completeWorkoutTapped(_ sender: Any) {
        
        for workout in exercisesArray {
            print(workout.name)
            print(workout.sets)
            print(workout.reps)
            print(workout.weights)
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
            
            // Path (users/uid/workouts/Exercises/NameofExercise/data)
            workoutData.collection("WorkoutExercises").document("\(exercisesArray[count].name)").setData(["Name": exercisesArray[count].name, "Notes": exercisesArray[count].notes, "Reps": exercisesArray[count].reps, "Sets": exercisesArray[count].sets, "Weight": exercisesArray[count].weights], merge: true)
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
        db.collection("users").document("\(userId)").collection("Workouts").document(name).collection("WorkoutExercises").getDocuments { (snapshot, error) in
            
            if error != nil {
                }
                else {
                    // For every document (exercise) in the database, copy the values and add them to the array
                    for document in snapshot!.documents {
                        
                        // Setting all the fields for each exercise
                        let exercise = Exercises()
                        exercise.name = document.documentID
                        let data:[String:Any] = document.data()
                        exercise.notes = data["Notes"] as! String
                        exercise.reps = data["Reps"] as! Int
                        exercise.weights = data["Weight"] as! Int
                        exercise.sets = data["Sets"] as! Int
                        
                        self.exercisesArray.append(exercise)
                        
                        // Reloading the data so it can be displayed
                        self.tableView.reloadData()
                }
            }
        }
    }
}
