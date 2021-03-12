//
//  FirstViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var AddNewWorkout: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "HomeCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    var addWorkOutTapped = false
    
    // Holds the most recent workout logged (DATE)
    var mostRecent = ""
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if delegate.firstLoad == true {
            getData()
            delegate.firstLoad = false
        } else {
            tableView.reloadData()
        }
        
        // Sets the screen for the ad
        bannerView.rootViewController = self
        
        // Id for the add, currently using a test ad
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        
        // Requests an ad
        bannerView.load(GADRequest())
        
        // Assigning the FirstViewController as the datasource of the tableview
        tableView.dataSource = self
        // Assigning the FirstViewController as the delegate of the tableview
        tableView.delegate = self
        
        // Makes lines that separate tableView cells invisible
        self.tableView.separatorColor = UIColor .clear
        
        tableView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        addWorkOutTapped = false
    }
    
    // MARK: - Tableview Functions
    
    // Returns the number of sections (# of workouts)
    func numberOfSections(in tableView: UITableView) -> Int {
        return Master.workouts.count
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
        let cell:HomeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HomeTableViewCell
        
        // Configure cell with data with the object in each array slot, (uses the section, not the row)
        let workout = Master.workouts[indexPath.section]
        
        // Setting the style of the cell
        Utilities.styleTableViewCells(cell)
        
        // Setting the cell information
        cell.setCell(workout)
        
        // States that the delegate of the cell is the view controller (Self)
        cell.delegate = self
        
        // Return the cell
        return cell
    }
    
    // MARK: - Cell ordering
    
    // Checks if the user is trying to move the table view cells around
    @IBAction func didTapSort(_ sender: Any) {
        if tableView.isEditing {
            
            // Get a reference to the database
            let db = Firestore.firestore()
            
            // Get current user ID
            let userId = Auth.auth().currentUser!.uid
            
            for i in 0...(Master.workouts.count - 1) {
                // Save changes in the database
                db.collection("users").document("\(userId)").collection("Workouts").document("\(Master.workouts[i].name)").setData(["Order": "\(i)"], merge: true)
            }
            
            tableView.isEditing = false
        }
        else {
            tableView.isEditing = true
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
                
                Master.workouts.swapAt(start, start + 1)
                
                // Increment start
                start += 1
            }
        } else if end < start {
            while (start != end) {
                
                Master.workouts.swapAt(start, start - 1)
                
                // Increment start
                start -= 1
            }
        }
        
        // Have to reload the tableview so 1 cell per section is enforced
        self.tableView.reloadData()
        
    }
    
    
    // MARK: - Reciving Information
    
    // Gets the data from the Popup screen
    @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        
        if (unwindSegue.source is EditWorkoutViewController || unwindSegue.source is AddWorkoutViewController) {
            // If you are coming back from EditWorkoutViewController, refresh the page
            Master.workouts.removeAll()
            getData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Sending data
    
    // Sending data to Workout started view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Check that a workout was tapped
        if tableView.indexPathForSelectedRow == nil {
            
            // Wipe the data to be sent over
            if addWorkOutTapped == true {
                // Setting data to pass over
                // Set a variable as an object of the viewcontroller we want to pass data to
                let sb2 = segue.destination as! AddWorkoutViewController
                sb2.clear = true
            }
            else {
                // Set a variable as an object of the viewcontroller we want to pass data to
                let sb2 = segue.destination as! EditWorkoutViewController
                sb2.clear = false
            }
        }
        
        guard tableView.indexPathForSelectedRow != nil else {
            return
        }
        
        // Get the workout that was tapped
        let selectedWorkout = Master.workouts[tableView.indexPathForSelectedRow!.section]
        
        // Set a variable as an object of the viewcontroller we want to pass data to
        let sb = segue.destination as! WorkoutStartedViewController
        
        // Setting data to pass over
        sb.workoutName = selectedWorkout.name
        
    }
    
    
    // MARK: - Pulling from database
    
    func getData() {
        
        // Get all the workout names from the database
        getAllWorkoutNames()
    }
    
    // MARK: - Get all workouts
    func getAllWorkoutNames() {
        
        // Getting the data to show workouts
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").order(by: "Order", descending: false).getDocuments { (snapshot, error) in
            
            if let error = error {
                print(error)
            }
            else {
                
                for document in snapshot!.documents {
                    
                    let workout = Workouts()
                    workout.name = document.documentID
                    Master.workouts.append(workout)
                    
                    // Get all exercises for a workout
                    self.getAllExercises(workoutName: workout.name)
                }
            }
        }
    }
    
    // MARK: - Get all exercises
    func getAllExercises(workoutName: String) {
        
        // Getting the data to show workouts
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").document(workoutName).collection("WorkoutExercises").order(by: "Order", descending: false).getDocuments { (snapshot, error) in
            
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
                    
                    exercise.totalSets = Int(data["numberofsets"] as! String)!
                    
                    var index = 0
                    // Checking where the workout is within the array
                    for i in 0...(Master.workouts.count - 1) {
                        if Master.workouts[i].name == workoutName {
                            index = i
                        }
                    }
                    
                    //Adds all the exercises of a particular workout to that workout
                    Master.workouts[index].exercises.append(exercise)
                    
                    // Adds the exercises to a master array
                    Master.exercises.append(exercise)
                    
                    // Get all the weights, reps, and sets for each exercise
                    self.checkForRecord(workoutName: workoutName, workoutArrayIndex: index, exerciseName: exercise.name, exercise: exercise)
                    
                    
                    // Reloading the data so it can be displayed
                    self.tableView.reloadData()
                    
                }
            }
        }
    }
    
    
    // MARK: - Check if theres a record
    func checkForRecord(workoutName: String, workoutArrayIndex: Int, exerciseName: String, exercise: Exercises) {
        
        // If there is historical data, it will be used to replace it
        db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutName).collection(exerciseName).order(by: "Date", descending: true).limit(to: 1).getDocuments() { (querySnapshot, err) in
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
                
                self.repsAndWeights1(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
                
                /*
                if querySnapshot!.documents.count > 0 {
                    
                    self.repsAndWeights1(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
                    
                    //self.mostRecentFunc(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
                } else {
                    self.repsAndWeights1(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
                }
                */
            }
        }
    }
    
    /*
    // MARK: - Get most recent
    func mostRecentFunc(workoutName: String, workoutArrayIndex: Int, exerciseName: String, exerciseArrayIndex: Int, exercise: Exercises) {
        
        // This function checks whether or not there are records in Workout Data, if there is, mostRecentDataExists is set to false and the following function will be ran instead
        // If mostRecentDataExists is true, then the following function to load the fields with default data is skipped
        
        // If there is historical data, it will be used to replace it
        db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutName).collection(exerciseName).order(by: "Date", descending: true).limit(to: 1).getDocuments() { (querySnapshot, err) in
            if err != nil {
                // Error
            } else {
                // Query did return something
                
                for document in querySnapshot!.documents {
                    
                    // Sets the date (mostRecent) as the document ID
                    self.mostRecent = document.documentID
                    
                    // There are records, pull the most recent one
                    self.repsAndWeightsUpdate(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
                }
            }
        }
    }
    */
    // MARK: - Default reps and weights
    
    func repsAndWeights1(workoutName: String, workoutArrayIndex: Int, exerciseName: String, exerciseArrayIndex: Int, exercise: Exercises) {
        
        for number in 0...(Master.workouts[workoutArrayIndex].exercises[exerciseArrayIndex].totalSets - 1) {
            
            exercise.sets.append(Sets())
            
            // There is no history, pull straight from Workouts
            let repsDbCall = db.collection("users").document("\(userId)").collection("Workouts").document(workoutName).collection("WorkoutExercises").document(exerciseName).collection("Set\(number + 1)").document("reps")
            
            repsDbCall.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    exercise.sets[number].reps = data["Reps\(number + 1)"] as! Int
                }
                else {
                    // There was an error, display it somehow
                }
            }
            
            // There is no history, pull straight from Workouts
            //Retrives the weights
            let weightsDbCall = db.collection("users").document("\(userId)").collection("Workouts").document(workoutName).collection("WorkoutExercises").document(exerciseName).collection("Set\(number + 1)").document("weights")
            
            weightsDbCall.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    exercise.sets[number].weights = data["Weight\(number + 1)"] as! Float
                    
                    self.tableView.reloadData()
                }
                else {
                    // There was an error, display it somehow
                }
            }
        }
    }
    
    // MARK: - Updated reps and weights
    /*
    func repsAndWeightsUpdate(workoutName: String, workoutArrayIndex: Int, exerciseName: String, exerciseArrayIndex: Int, exercise: Exercises) {
        
        // Grayed out for now to test new queries where workout is used as the front facing array of data
        
        for number in 0...(Master.workouts[workoutArrayIndex].exercises[exerciseArrayIndex].totalSets - 1) {
            
            exercise.sets.append(Sets())
            
            // Retrives the reps
            let repsDbCallHistory = db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutName).collection(exerciseName).document(mostRecent).collection("Set\(number + 1)").document("reps")
            
            repsDbCallHistory.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    exercise.sets[number].reps = data["Reps\(number + 1)"] as! Int
                }
                else {
                    // error
                }
            }
            
            //Retrives the weights
            let weightsDbCallHistory = db.collection("users").document("\(userId)").collection("WorkoutData").document(workoutName).collection(exerciseName).document(mostRecent).collection("Set\(number + 1)").document("weights")
            
            weightsDbCallHistory.getDocument { (document, error) in
                if let document = document, document.exists {
                    // For every document (Set) in the database, copy the values and add them to the array
                    
                    let data:[String:Any] = document.data()!
                    
                    exercise.sets[number].weights = data["Weight\(number + 1)"] as! Int
                    
                    self.tableView.reloadData()
                }
                else {
                    // error
                }
            }
        }
 
    }
         */
    // MARK: - Logic help
    
    @IBAction func AddWorkoutTapped(_ sender: Any) {
        
        // Sets variable for the workout to be true
        addWorkOutTapped = true
    }
    
    
}

// Says the viewcontroller conforms to the HomeCellDelegate protocol, we can get the name this way
extension HomeViewController: HomeCellDelegate {
    func didTapEdit(name: String) {
        
        StructVariables.nameOfWorkout = name
    }
}
