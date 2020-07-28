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

    // Array holding all exercises for a workout
    var exerciseArrayCopy = [Exercises]()
    
    // Array of Workouts to send back (empty at first)
    var workoutsArray = [Workouts]()
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var workoutName: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // Variable to keep track of when the workout is done being made, this stops the prepare for segue from firing constantly when we dont want to add objects to our array
    var buttonTapped = false

    
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
            let workout = db.collection("users").document("\(userId)").collection("\(name)")
            
            for num in 0...(exerciseArrayCopy.count - 1) {
                workout.document("\(exerciseArrayCopy[num].name)").setData(["Name": exerciseArrayCopy[num].name, "Notes": exerciseArrayCopy[num].notes, "Reps": exerciseArrayCopy[num].reps, "Sets": exerciseArrayCopy[num].sets, "Weight": exerciseArrayCopy[num].weights], merge: false)
            }
            
            // Transitioning the screen back to add exercise screen
            performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Formating the text fields
        formatTextField(workoutName)
        
        tableView.delegate = self
        tableView.dataSource = self
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
}
