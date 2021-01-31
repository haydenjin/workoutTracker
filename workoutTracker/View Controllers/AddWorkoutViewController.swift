//
//  AddWorkoutViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class AddWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "WorkoutExercisesCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    // Array holding all exercises for a workout
    var exerciseArrayCopy = [Exercises]()
    
    // Array of Workouts to send back (empty at first)
    var workoutsArray = [Workouts]()
    
    var workoutNameCopy = ""
    
    var clear = false
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // Variable to keep track of when the workout is done being made, this stops the prepare for segue from firing constantly when we dont want to add objects to our array
    var buttonTapped = false
    
    // MARK: - Save completed workout in database
    
    @IBAction func completeWorkoutTapped(_ sender: Any) {
        
        // Turns the button to true
        buttonTapped = true
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil || exerciseArrayCopy.count == 0 {
            // There was an error
            // Change the error label and make it visible
            errorLabel.text = error
            errorLabel.alpha = 1
        }
        else {
            // Get a reference to the database
            let db = Firestore.firestore()
            
            // Get current user ID
            let userId = Auth.auth().currentUser!.uid
            
            // Setting the name of the workout
            let name = workoutName.text!
            
            // Adds the array of exercises to the database
            let workout = db.collection("users").document("\(userId)").collection("Workouts").document(name)
            
            // Add a random message so Workouts will appear in queries (Not a virtual document)
            workout.setData(["Set": "Not virtual"])
            
            let WorkoutExercises = workout.collection("WorkoutExercises")
            
            // Loop for each exercise
            for num in 0...(exerciseArrayCopy.count - 1) {
                //workout.setData(["Message": "Default"])
                
                // Name of individual exercise
                let workout = WorkoutExercises.document("\(exerciseArrayCopy[num].name)")
                
                // Adding the note
                workout.setData(["Notes": String(exerciseArrayCopy[num].notes)], merge: true)
                
                // Add the count for number of reps
                workout.setData(["numberofsets": String(exerciseArrayCopy[num].sets.count)], merge: true)
                
                // Loop for sets for each exercise
                for set in 1...exerciseArrayCopy[num].sets.count {
                    workout.collection("Set" + String(set)).document("reps").setData(["Reps\(set)": exerciseArrayCopy[num].sets[set - 1].reps], merge: true)
                    
                    workout.collection("Set" + String(set)).document("weights").setData(["Weight\(set)": exerciseArrayCopy[num].sets[set - 1].weights], merge: true)
                }
            }
            
            // Transitioning the screen back to add exercise screen
            performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        }
    }
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if clear == true {
            StructVariables.nameOfWorkout = ""
        }
        
        workoutNameCopy = StructVariables.nameOfWorkout
        workoutName.text = workoutNameCopy
        
        getData()
        
        // Formating the text fields
        formatTextField(workoutName)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Makes lines that separate tableView cells invisible
        self.tableView.separatorColor = UIColor .clear
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reloading the data so it can be displayed
        tableView.reloadData()
    }
    
    // MARK: - Validation
    
    // Checks if all required fields are filled out
    func validateFields() -> String? {
        
        // Check that all required fields are filled while removing white spaces and new lines
        if workoutName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            // Fields not filled, Display error message
            return "Please fill in the workout name and add an exercise"
        }
        // Fields are filled, keep going
        return nil
    }
    
    // MARK: - TableView Functions
    
    // Returns the number of sections (# of workouts)
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.exerciseArrayCopy.count
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutExercisesCell", for: indexPath) as! WorkoutExercisesTableViewCell
        
        // Configure cell with data with the object in each array slot
        let exercise = self.exerciseArrayCopy[indexPath.section]
        
        cell.setCell(exercise)
        
        Utilities.styleTableViewCells(cell)
        
        // States that the delegate of the cell is the view controller (Self)
        cell.delegate = self
        
        // Return the cell
        return cell
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
    
    
    // MARK: - Sending back information
    
    // Function needed to pass data back to a previous viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Checks if the button was tapped
        if buttonTapped == true {
            
            // Creating the workout to be sent back
            let workout = Workouts()
            workout.name = workoutName.text!
            workout.exercises = exerciseArrayCopy
            workoutsArray.append(workout)
        }
    }
    
    // MARK: - Reciving Information
    
    // Gets the data from the Popup screen
    @IBAction func unwindToAddExercise(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? PopupViewController {
            
            // Copying the data from the other viewcontroller and combining (Merging) the arrays
            exerciseArrayCopy += sourceViewController.exerciseArray
        }
    }
    
    func getData() {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Get current user ID
        let userId = Auth.auth().currentUser!.uid
        
        if workoutNameCopy == "" {
            return
        }
        
        // Getting the data to show exercises
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").document(workoutNameCopy).collection("WorkoutExercises").getDocuments { (snapshot, error) in
            
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
                    
                    /*
                    for num in 0...exercise.sets.count {
                        exercise.sets[num].reps = data["Reps1"] as! Int
                        exercise.sets[num].weights = data["Weight1"] as! Int
                    }
                    */
                    self.exerciseArrayCopy.append(exercise)
                    
                    // Reloading the data so it can be displayed
                    self.tableView.reloadData()
                }
            }
        }
    }
}

// MARK: - Conforming to delegates

// Says the viewcontroller conforms to the WorkoutCell protocol, we can get the name this way
extension AddWorkoutViewController: WorkoutCellDelegate {
    func didTapDelete(name: String) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Get current user ID
        let userId = Auth.auth().currentUser!.uid
        
        // Deleting the exercise
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").document(workoutNameCopy).collection("WorkoutExercises").document(name).delete()
        
        for count in 0...(exerciseArrayCopy.count - 1) {
            if exerciseArrayCopy[count].name == name {
                exerciseArrayCopy.remove(at: count)
                break
            }
        }
        
        tableView.reloadData()
    }
}
