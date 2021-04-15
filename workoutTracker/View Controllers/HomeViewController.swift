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
import Purchases
import AppTrackingTransparency
import AdSupport

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet weak var AddNewWorkout: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var sortButton: UIButton!
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "HomeCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    // Holds the most recent workout logged (DATE)
    var mostRecent = ""
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    let seconds = 0.3
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        if delegate.firstLoad == true {
            if StructVariables.getDataCalled == false {
                
                Master.workouts.removeAll()
                Master.exercises.removeAll()
                getData()
                StructVariables.getDataCalled = true
                delegate.firstLoad = false
                getLastPerformed()
            }
        } else if StructVariables.comingFromLogin == true {
            if StructVariables.getDataCalled == false {
                
                Master.workouts.removeAll()
                Master.exercises.removeAll()
                getData()
                StructVariables.getDataCalled = true
                StructVariables.comingFromLogin = false
                getLastPerformed()
            }
        }
        
        db.collection("users").document("\(userId)").getDocument { (document, error) in
            if let document = document, document.exists {
                
                let data:[String:Any] = document.data()!
                
                self.welcomeLabel.text = "Welcome \(data["firstname"] as! String)! "
                
            }
        }
        
        getLastPerformed()
        
        // Assigning the FirstViewController as the datasource of the tableview
        tableView.dataSource = self
        // Assigning the FirstViewController as the delegate of the tableview
        tableView.delegate = self
        
        bannerView.delegate = self
        
        // Makes lines that separate tableView cells invisible
        self.tableView.separatorColor = UIColor .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds + 0.2) {
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        requestIDFA()
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
        
        print(GADMobileAds.sharedInstance().sdkVersion)
    }
    
    func requestIDFA() {
      ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
        // Tracking authorization completed. Start loading ads here.
        // If user does not have premium load an ad
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["pro"]?.isActive != true {
                
                // Id for the ad, (Test ad)
                self.bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
                
                // Id for the ad, (Live ad)
                self.bannerView.adUnitID = "ca-app-pub-3755886742417549/4499662760"
                
                // Sets the screen for the ad
                self.bannerView.rootViewController = self
                
                // Requests an ad
                self.bannerView.load(GADRequest())
            }
        }
      })
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
            
            sortButton.setTitle("Sort", for: .normal)
            sortButton.setTitleColor(.systemBlue, for: .normal)
        }
        else {
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
            Master.exercises.removeAll()
            getData()
            tableView.reloadData()
        }
    }
    
    // MARK: - Sending data
    
    // Sending data to Workout started view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Check that a workout was tapped
        if tableView.indexPathForSelectedRow == nil {
            
            // Set a variable as an object of the viewcontroller we want to pass data to
            let sb2 = segue.destination as! EditWorkoutViewController
            sb2.clear = false
            
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
    
    func getLastPerformed() {
        
        // Getting the data to show workouts
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").order(by: "Order", descending: false).getDocuments { (snapshot, error) in
            
            if let error = error {
                print(error)
            }
            else {
                
                Master.lastPerformed.removeAll()
                
                for document in snapshot!.documents {
                    
                    self.db.collection("users").document("\(self.userId)").collection("LastPerformed").document(document.documentID).getDocument { (document, error) in
                        if let document = document, document.exists {
                            
                            let data:[String:Any] = document.data()!
                            
                            let record = LastPerformed()
                            record.addNewRecord(name: document.documentID, lastPerformed: (data["Date"] as! String))
                            Master.lastPerformed.append(record)
                        }
                    }
                }
            }
        }
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
                    
                    self.db.collection("users").document("\(self.userId)").collection("LastPerformed").document(document.documentID).getDocument { (document, error) in
                        if let document = document, document.exists {
                            
                            let data:[String:Any] = document.data()!
                            
                            let record = LastPerformed()
                            record.addNewRecord(name: document.documentID, lastPerformed: (data["Date"] as! String))
                            Master.lastPerformed.append(record)
                        }
                    }
                    
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
                
            }
        }
    }
    
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
    
    // MARK: - Refresh the screen
    
    @IBAction func refreshTapped(_ sender: Any) {
        
        // Call view did load to re-get the data
        viewDidLoad()
    }
    
    
    // MARK: - Logic help
    
    @IBAction func AddWorkoutTapped(_ sender: Any) {
        
        StructVariables.numberOfWorkouts = Master.workouts.count
        
        // Check if the user has premium
        Purchases.shared.purchaserInfo { (purchaserInfo, error) in
            
            if purchaserInfo?.entitlements.all["pro"]?.isActive != true {
                
                // If made into here user doesn't have pro content
                if StructVariables.numberOfWorkouts >= 5 {
                    
                    // Moves to pro view controller
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProViewController") as! ProViewController
                    newViewController.modalPresentationStyle = .fullScreen
                    self.present(newViewController, animated: true, completion: nil)
                    
                    return
                } else {
                    // Moves to add workout viewcontroller
                    
                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddExercise") as! AddWorkoutViewController
                    newViewController.modalPresentationStyle = .fullScreen
                    newViewController.clear = true
                    self.present(newViewController, animated: true, completion: nil)
                    return
                }
            } else {
                // Moves to add workout viewcontroller
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "AddExercise") as! AddWorkoutViewController
                newViewController.modalPresentationStyle = .fullScreen
                newViewController.clear = true
                self.present(newViewController, animated: true, completion: nil)
                return
            }
        }
    }
}

// Says the viewcontroller conforms to the HomeCellDelegate protocol, we can get the name this way
extension HomeViewController: HomeCellDelegate {
    func didTapEdit(name: String) {
        
        StructVariables.nameOfWorkout = name
    }
}
