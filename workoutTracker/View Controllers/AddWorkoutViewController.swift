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
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
    // Index of the workout
    var index = 0
    
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
        
        if error != nil || Master.workouts[index].exercises.count == 0 {
            // There was an error
            // Change the error label and make it visible
            errorLabel.text = error
            errorLabel.alpha = 1
            
            buttonTapped = false
        }
        else {
            
            // Setting the name of the workout
            var name = workoutName.text!
            
            name = Utilities.onlyLettersOrNumbers(name)
            
            // Adds the array of exercises to the database
            let workout = db.collection("users").document(userId).collection("Workouts").document(name)
            
            // Add a random message so Workouts will appear in queries (Not a virtual document)
            workout.setData(["Set": "Not virtual"], merge: true)
            
            // Set order to be 0, so it will start off as the start of the list
            workout.setData(["Order": -1], merge: true)
            
            let WorkoutExercises = workout.collection("WorkoutExercises")
            
            // Loop for each exercise
            for num in 0...(Master.workouts[index].exercises.count - 1) {
                
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

    // Function needed to pass data back to a previous viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if (segue.identifier == "backToHome") {
            // Checks if the button was tapped
            if buttonTapped == false {
                // Button wasn't tapped, no workout was created so get rid of extra workout
                Master.workouts.removeLast()
            }
        }
    }

    // MARK: - Reciving Information
    
    // Gets the data from the Popup screen
    @IBAction func unwindToAddExercise(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? PopupViewController {
            
            // Copying the data from the other viewcontroller and combining (Merging) the arrays
            Master.workouts[index].exercises += sourceViewController.exerciseArray
        }
    }
    
    func getData() {
        
        if workoutNameCopy == "" {
            Master.workouts.append(Workouts())
            self.index = Master.workouts.count - 1
            return
        }
        
        for i in 0...Master.workouts.count - 1 {
            if Master.workouts[i].name == workoutNameCopy {
                self.index = i
            }
        }
    }
}

// MARK: - Conforming to delegates

// Says the viewcontroller conforms to the WorkoutCell protocol, we can get the name this way
extension AddWorkoutViewController: WorkoutCellDelegate {
    func didTapDelete(name: String) {
        
        for count in 0...(Master.workouts[index].exercises.count - 1) {
            if Master.workouts[index].exercises[count].name == name {
                Master.workouts[index].exercises.remove(at: count)
                break
            }
        }
        
        tableView.reloadData()
    }
    
    func didTapEdit(name: String) {
        // Need to have function to conform
    }
}
