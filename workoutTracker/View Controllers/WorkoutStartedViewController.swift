//
//  WorkoutStartedViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-29.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase
import StoreKit

class WorkoutStartedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var nameOfWorkout: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var sortButton: UIButton!
    
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "ActiveWorkoutCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    var workoutName = ""
    
    // Index of the workout
    var index = 0
    
    // Array holding all exercises for a workout
    //var exercisesArray = [Exercises]()
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        getData(workoutName: workoutName)
        
        // Name is passed in by HomeViewController
        nameOfWorkout.text = workoutName
        
        tableView.delegate = self
        
        tableView.dataSource = self
        
        // Makes lines that separate tableView cells invisible
        self.tableView.separatorColor = UIColor .clear
        
    }
    
    // MARK: - Tableview Functions
    
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
    
    // Removes the red delete button when editing tableview
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    // Removes the red delete button when editing tableview
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Picking what cell displays this data
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ActiveWorkoutTableViewCell
        
        // Configure cell with data with the object in each array slot
        let exercise = Master.workouts[index].exercises[indexPath.section]
        
        // Setting the style of the cell
        Utilities.styleTableViewCells(cell)
        
        cell.setCell(exercise)
        
        // Return the cell
        return cell
    }
    
    // MARK: - Cell ordering
    
    // Checks if the user is trying to move the table view cells around
    @IBAction func sortButtonTapped(_ sender: Any) {
        
        if tableView.isEditing {
            
            if Master.workouts.count == 0 {
                return
            }
            
            // Get a reference to the database
            let db = Firestore.firestore()
            
            // Get current user ID
            let userId = Auth.auth().currentUser!.uid
            
            for i in 0...(Master.workouts[index].exercises.count - 1) {
                // Save changes in the database
                db.collection("users").document("\(userId)").collection("Workouts").document("\(workoutName)").collection("WorkoutExercises").document("\(Master.workouts[index].exercises[i].name)").setData(["Order": "\(i)"], merge: true)
            }
            
            tableView.isEditing = false
            
            sortButton.setTitle("Sort", for: .normal)
            sortButton.setTitleColor(.systemBlue, for: .normal)
        }
        else {
            
            if Master.workouts.count == 0 {
                return
            }
            
            tableView.isEditing = true
            
            sortButton.setTitle("Save", for: .normal)
            sortButton.setTitleColor(.red, for: .normal)
        }
    }
    
    // Lets tableview cells be moved
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Swaps the tableview cells
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        var start = sourceIndexPath.section
        
        let end = destinationIndexPath.section
        
        if start < end {
            while (start != end) {
                
                Master.workouts[index].exercises.swapAt(start, start + 1)
                
                // Increment start
                start += 1
            }
        } else if end < start {
            while (start != end) {
                
                Master.workouts[index].exercises.swapAt(start, start - 1)
                
                // Increment start
                start -= 1
            }
        }
        
        // Have to reload the tableview so 1 cell per section is enforced
        self.tableView.reloadData()
        
    }
    
    // MARK: - Load exercises from master array
    
    func getData(workoutName: String) {
        
        for i in 0...Master.workouts.count - 1 {
            if Master.workouts[i].name == workoutName {
                self.index = i
            }
        }
        
        if Master.workoutCheck.count == 0 {
            for i in 0...Master.workouts[self.index].exercises.count - 1 {
                
                let workoutCheck = WorkoutChecker()
                workoutCheck.addNewRecord(name: Master.workouts[index].exercises[i].name, done: false)
                
                Master.workoutCheck.append(workoutCheck)
            }
        }
    }
    
    // MARK: - Completing workout
    
    // Sends data of finished workout back to database
    @IBAction func completeWorkoutTapped(_ sender: Any) {
        
        var allDone = true
        
        if Master.workoutCheck.count > 0 {
            
            for i in 0...Master.workoutCheck.count - 1 {
                if Master.workoutCheck[i].done == false {
                    
                    allDone = false
                }
            }
        }
        
        if allDone == false {
            
            // Create a message
            let confirmMessage = UIAlertController(title: "Confirm", message: "You still have incomplete exercises, are you sure you want to complete the workout now?", preferredStyle: .alert)
            
            // Delete option
            let delete = UIAlertAction(title: "Complete Now", style: .default, handler: { (action) -> Void in
                
                Master.workoutCheck.removeAll()
                
                // Save the date that workout was performed
                
                // Get a reference to the database
                let db = Firestore.firestore()
                
                // Get current user ID
                let userId = Auth.auth().currentUser!.uid
                
                // Getting the current date
                let df = DateFormatter()
                df.dateFormat = "MMM-dd"
                let date = df.string(from: Date())

                db.collection("users").document("\(userId)").collection("LastPerformed").document("\(self.workoutName)").setData(["Date": date])
                
                
                // Ask user to rate the app
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
                
                self.performSegue(withIdentifier: "returnToHome", sender: self)
            })
             
            // Cancel option
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in })

            // Add the options to the message
            confirmMessage.addAction(delete)
            confirmMessage.addAction(cancel)
            
            self.present(confirmMessage, animated: true, completion: nil)
            
        }

        /*
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
         */
        
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
    
    
    
    // MARK: - Sending data to ExerciseVC
    
    // Sending data to Workout started view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Check that a workout was tapped
        guard tableView.indexPathForSelectedRow != nil else {
            return
        }
        
        // Get the workout that was tapped
        let selectedExercise = Master.workouts[index].exercises[tableView.indexPathForSelectedRow!.section]
        
        // Set a variable as an object of the viewcontroller we want to pass data to
        let sb = segue.destination as! ExerciseViewController
        
        sb.workoutName = workoutName
        
        // Setting data to pass over
        sb.exerciseName = selectedExercise.name
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        var allDone = true
        
        if Master.workoutCheck.count >= 0 {
            
            for i in 0...Master.workoutCheck.count - 1 {
                if Master.workoutCheck[i].done == true {
                    
                    allDone = false
                }
            }
        }

        if allDone == false {
            
            // Create a message
            let confirmMessage = UIAlertController(title: "Confirm", message: "You still have incomplete exercises, are you sure you want to complete the workout now?", preferredStyle: .alert)
            
            // Delete option
            let delete = UIAlertAction(title: "Complete Now", style: .default, handler: { (action) -> Void in
                
                Master.workoutCheck.removeAll()
                
                self.performSegue(withIdentifier: "returnToHome", sender: self)
            })
            
            // Cancel option
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) -> Void in })

            // Add the options to the message
            confirmMessage.addAction(delete)
            confirmMessage.addAction(cancel)
            
            self.present(confirmMessage, animated: true, completion: nil)
            
        }
    }
}
