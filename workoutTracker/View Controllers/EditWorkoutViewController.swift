//
//  EditWorkoutViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-02-03.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class EditWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "WorkoutExercisesCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    var workoutNameCopy = ""
    
    var exerciseNameCopy = ""
    
    // Index of the workout
    var index = 0
    
    var clear = false
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
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
        
        if error != nil || Master.workouts[index].exercises.count == 0 {
            // There was an error
            // Change the error label and make it visible
            errorLabel.text = error
            errorLabel.alpha = 1
        }
        else {
            
            // Want to check if name of workout was changed
            if (workoutNameCopy != workoutName.text) {
                // Name was changed
                
                // Delete old document in database
                db.collection("users").document("\(userId)").collection("Workouts").document(workoutNameCopy).delete()
                // Refresh the Home page
            }
            
            // MARK: - Save in workouts
            
            // Setting the name of the workout
            var name = workoutName.text!
            
            name = Utilities.onlyLettersOrNumbers(name)
            
            // Adds the array of exercises to the database
            let workout = db.collection("users").document(userId).collection("Workouts").document(name)
            
            // Add a random message so Workouts will appear in queries (Not a virtual document)
            workout.setData(["Set": "Not virtual"], merge: true)
            
            // Add a random order for now
            workout.setData(["Order": 0], merge: true)
            
            let WorkoutExercises = workout.collection("WorkoutExercises")
            
            // Loop for each exercise
            for num in 0...(Master.workouts[index].exercises.count - 1) {
                //workout.setData(["Message": "Default"])
                
                // Name of individual exercise
                let workout = WorkoutExercises.document("\(Master.workouts[index].exercises[num].name)")
                
                // Adding the note
                workout.setData(["Notes": String(Master.workouts[index].exercises[num].notes)], merge: true)
                
                // Add the count for number of reps
                workout.setData(["numberofsets": String(Master.workouts[index].exercises[num].sets.count)], merge: true)
                
                // Add a random order for now
                workout.setData(["Order": 0], merge: true)
                
                // Loop for sets for each exercise
                for set in 1...Master.workouts[index].exercises[num].sets.count {
                    workout.collection("Set" + String(set)).document("reps").setData(["Reps\(set)": Master.workouts[index].exercises[num].sets[set - 1].reps], merge: true)
                    
                    workout.collection("Set" + String(set)).document("weights").setData(["Weight\(set)": Master.workouts[index].exercises[num].sets[set - 1].weights], merge: true)
                }
            }
            
            // MARK: - Save in workoutData
            /*
            // Check if there is a record, if there is, set the
            db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutNameCopy).collection(exerciseNameCopy).order(by: "Date", descending: true).limit(to: 1).getDocuments() { (querySnapshot, err) in
                if err != nil {
                    // Error
                } else {
                    // Query did return something
                    
                    var exerciseArrayIndex = 0
                    
                    // Gets the proper exercise
                    for i in 0...Master.workouts[workoutArrayIndex].exercises.count - 1 {
                        if Master.workouts[workoutArrayIndex].exercises[i].name == exerciseName {
                            exerciseArrayIndex = i
                        }
                    }
                    
                    if querySnapshot!.documents.count > 0 {
                        self.mostRecentFunc(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
                    } else {
                        self.repsAndWeights1(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
                    }
                }
            }
            */
            
            // Transitioning the screen back to add exercise screen
            performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        }
    }
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
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
        return Master.workouts[index].exercises.count
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
        let exercise = Master.workouts[index].exercises[indexPath.section]
        
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
    /*
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
     */
    // MARK: - Reciving Information
    
    // Gets the data from the Popup screen
    @IBAction func unwindToAddExercise(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? PopupViewController {
            
            // Copying the data from the other viewcontroller and combining (Merging) the arrays
            Master.workouts[index].exercises += sourceViewController.exerciseArray
            
            tableView.reloadData()
        }
    }
    
    func getData() {
        
        for i in 0...Master.workouts.count - 1 {
            if Master.workouts[i].name == workoutNameCopy {
                self.index = i
            }
        }
    }
    
    // MARK: - Sending data to EditExerciseVC
    
    // Sending data to Edit Workout
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "editExercise" {
            
            let sb = segue.destination as! EditExerciseViewController
            sb.workoutName = workoutNameCopy
            
            sb.exerciseName = exerciseNameCopy
        }
    }
    
    
    // MARK: - Delete workout
    
    @IBAction func deleteWorkout(_ sender: Any) {
        
        // Create a message
        let confirmMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        
        // Delete option
        let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
            
            // Delete the workout from the database
            self.db.collection("users").document("\(self.userId)").collection("Workouts").document(self.workoutNameCopy).delete()
            // Send the screen back to home
            self.performSegue(withIdentifier: "unwindSegueToHome", sender: self)
        })
        
        // Cancel option
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in })

        // Add the options to the message
        confirmMessage.addAction(delete)
        confirmMessage.addAction(cancel)
        
        self.present(confirmMessage, animated: true, completion: nil)
    }
}

// MARK: - Conforming to delegates

// Says the viewcontroller conforms to the WorkoutCell protocol, we can get the name this way
extension EditWorkoutViewController: WorkoutCellDelegate {
    func didTapDelete(name: String) {
        
        // Create a message
        let confirmMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this?", preferredStyle: .alert)
        
        // Delete option
        let delete = UIAlertAction(title: "Delete", style: .default, handler: { (action) -> Void in
            
            // Deleting the exercise
            // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
            self.db.collection("users").document("\(self.userId)").collection("Workouts").document(self.workoutNameCopy).collection("WorkoutExercises").document(name).delete()
            
            for count in 0...(Master.workouts[self.index].exercises.count - 1) {
                if Master.workouts[self.index].exercises[count].name == name {
                    Master.workouts[self.index].exercises.remove(at: count)
                    break
                }
            }
            
            self.tableView.reloadData()
        })
        
        // Cancel option
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in })

        // Add the options to the message
        confirmMessage.addAction(delete)
        confirmMessage.addAction(cancel)
        
        self.present(confirmMessage, animated: true, completion: nil)
    }

    
// Button to edit workout
    func didTapEdit(name: String) {
        
        exerciseNameCopy = name
    }
}
