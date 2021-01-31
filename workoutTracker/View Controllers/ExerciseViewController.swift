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
    var exercise = Exercises.VariableExercises()
    
    // Tracks if the user hit the done button
    var doneTapped = false
    
    // Holds the most recent workout logged (DATE)
    var mostRecent = ""
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
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
        return exercise.totalSets
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
            cell.getNewInfo(exercise)
            
            // If statement so loop only runs once (Limits reads and writes to database)
            if StructVariables.count2 == exercise.totalSets {
                
                // Adds the array of exercises to the database
                let workout = db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutName)
                
                workout.setData(["Set": "Not virtual"])
                
                // Getting the current date
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                let date = df.string(from: Date())
                
                workout.collection(exerciseName).document(date).setData(["Set": "Not virtual"], merge: true)
                
                workout.collection(exerciseName).document(date).setData(["Date": date], merge: true)
                
                
                for count in 0...exercise.totalSets-1 {
                    
                    // Saves reps
                    workout.collection(exerciseName).document(date).collection("Set\(count + 1)").document("reps").setData(["Reps\(count+1)": exercise.sets[count].reps], merge: true)
                    
                    // Saves weights
                    workout.collection(exerciseName).document(date).collection("Set\(count + 1)").document("weights").setData(["Weight\(count+1)": exercise.sets[count].weights], merge: true)
                }
            }
        }
        // Button wasn't tapped, set up tableview cells like usual
        else {
            
            // Start setting the fields
            cell.setNum.text = "Set \(indexPath.row + 1)"
            cell.reps.text = "\(exercise.sets[indexPath.row].reps)"
            cell.weight.text = "\(exercise.sets[indexPath.row].weights)"
            
            cell.formatCell(exercise)
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
    
    // MARK: - Check if theres a record
    
    func checkForRecord() {
        
        // If there is historical data, it will be used to replace it
        db.collection("users").document("\(userId)").collection("WorkoutData").document(self.workoutName).collection(self.exerciseName).order(by: "Date", descending: true).limit(to: 1).getDocuments() { (querySnapshot, err) in
            if err != nil {
                // Error
            } else {
                // Query did return something
                
                if querySnapshot!.documents.count > 0 {
                    self.mostRecentFunc()
                } else {
                    self.repsAndWeights1()
                }
            }
        }
    }

    // MARK: - Get most recent
    
    func mostRecentFunc() {
        
        // This function checks whether or not there are records in Workout Data, if there is, mostRecentDataExists is set to false and the following function will be ran instead
        // If mostRecentDataExists is true, then the following function to load the fields with default data is skipped
        
        // If there is historical data, it will be used to replace it
        db.collection("users").document("\(userId)").collection("WorkoutData").document(self.workoutName).collection(self.exerciseName).order(by: "Date", descending: true).limit(to: 1).getDocuments() { (querySnapshot, err) in
            if err != nil {
                // Error
            } else {
                // Query did return something
                
                for document in querySnapshot!.documents {

                    // Sets the date (mostRecent) as the document ID
                    self.mostRecent = document.documentID
                    
                    // There are records, pull the most recent one
                    self.repsAndWeightsUpdate()
                }
            }
        }
    }
    
    // MARK: - Default reps and weights
    
    func repsAndWeights1() {
        
        for number in 0...(self.exercise.totalSets - 1) {
            
            self.exercise.sets.append(Sets())
            
            // There is no history, pull straight from Workouts
            let repsDbCall = db.collection("users").document("\(userId)").collection("Workouts").document(self.workoutName).collection("WorkoutExercises").document(self.exerciseName).collection("Set\(number + 1)").document("reps")
            
            repsDbCall.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    self.exercise.sets[number].reps = data["Reps\(number + 1)"] as! Int
                }
                else {
                    // There was an error, display it somehow
                }
            }

            // There is no history, pull straight from Workouts
            //Retrives the weights
            let weightsDbCall = db.collection("users").document("\(userId)").collection("Workouts").document(self.workoutName).collection("WorkoutExercises").document(self.exerciseName).collection("Set\(number + 1)").document("weights")
            
            weightsDbCall.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    self.exercise.sets[number].weights = data["Weight\(number + 1)"] as! Int
                    
                    self.tableView.reloadData()
                }
                else {
                    // There was an error, display it somehow
                }
            }
        }
    }
    
    // MARK: - Updated reps and weights
    
    func repsAndWeightsUpdate() {
        
        for number in 0...(self.exercise.totalSets - 1) {
            
            self.exercise.sets.append(Sets())
            
            // Retrives the reps
            let repsDbCallHistory = db.collection("users").document("\(userId)").collection("WorkoutData").document(self.workoutName).collection(self.exerciseName).document(mostRecent).collection("Set\(number + 1)").document("reps")
            
            repsDbCallHistory.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    self.exercise.sets[number].reps = data["Reps\(number + 1)"] as! Int
                }
                else {
                    // error
                }
            }
            
            //Retrives the weights
            let weightsDbCallHistory = db.collection("users").document("\(userId)").collection("WorkoutData").document(self.workoutName).collection(self.exerciseName).document(mostRecent).collection("Set\(number + 1)").document("weights")
            
            weightsDbCallHistory.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    self.exercise.sets[number].weights = data["Weight\(number + 1)"] as! Int
                    
                    self.tableView.reloadData()
                }
                else {
                    // error
                }
            }
        }
    }
    
    // MARK: - Pulling name, notes & set #
    func getData() {
        
        // Getting the data to show workouts
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").document(self.workoutName).collection("WorkoutExercises").document(self.exerciseName).getDocument { (document, error) in
            if let document = document, document.exists {
                
                self.exercise = Exercises.VariableExercises()
                self.exercise.name = self.exerciseName
                
                let data:[String:Any] = document.data()!
                
                self.exercise.notes = data["Notes"] as! String
                // Need to do this since it is listed as a String in the database so using as! Int crashes the program
                self.exercise.totalSets = Int(data["numberofsets"] as! String)!
                
                self.checkForRecord()
            }
        }
    }
}
