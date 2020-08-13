//
//  FirstViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//


// Uncomment out functions when ready

import UIKit
import Firebase


class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var AddNewWorkout: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    // Varable for the cell identifier
    let cellReuseIdentifier = "HomeCell"
    
    // Variable for spacing between rows (Sections)
    let cellSpacingHeight: CGFloat = 10
    
    var addWorkOutTapped = false
    
    // An array of Workouts which is empty at first
    var workouts = [Workouts]()
    
    
    // MARK: - View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
        
        // Code that I commented out because it was causing a crash, On stack overflow it said you need it but i guess not?
        //self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // Assigning the FirstViewController as the datasource of the tableview
        tableView.dataSource = self
        // Assigning the FirstViewController as the delegate of the tableview
        tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reloading the data so it can be displayed
        tableView.reloadData()
    }
    
    // MARK: - Tableview Functions
    
    // Returns the number of sections (# of workouts)
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.workouts.count
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
        let cell:HomeTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! HomeTableViewCell
        
        // Configure cell with data with the object in each array slot, (uses the section, not the row)
        let workout = self.workouts[indexPath.section]
        
        // Setting the style of the cell
        Utilities.styleTableViewCells(cell)
        
        // Setting the cell information
        cell.setCell(workout)
        
        // States that the delegate of the cell is the view controller (Self)
        cell.delegate = self
        
        // Return the cell
        return cell
    }

    // MARK: - Reciving Information

        // Gets the data from the Popup screen
        @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? AddWorkoutViewController {
            
            for workout in workouts {
                for workout2 in sourceViewController.workoutsArray {
                    
                    if workout.name == workout2.name {
                        return
                    }
                    else {
                        
                        // Copying the data from the other viewcontroller and combining (Merging) the arrays
                        workouts += sourceViewController.workoutsArray
                        
                    }
                }
            }
        }
    }

    // MARK: - Sending data
    
    // Sending data to Workout started view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if addWorkOutTapped == true {
            
            // Check that a workout was tapped
            guard tableView.indexPathForSelectedRow != nil else {
                return
            }
            
            // Set a variable as an object of the viewcontroller we want to pass data to
            let sb = segue.destination as! WorkoutStartedViewController
            
            // Setting data to pass over
            sb.name = ""
        }
        else {
            
            // Check that a workout was tapped
            guard tableView.indexPathForSelectedRow != nil else {
                return
            }
            
            // Get the workout that was tapped
            let selectedWorkout = workouts[tableView.indexPathForSelectedRow!.row]
            
            // Set a variable as an object of the viewcontroller we want to pass data to
            let sb = segue.destination as! WorkoutStartedViewController
            
            // Setting data to pass over
            sb.name = selectedWorkout.name
        }
    }
    

    // MARK: - Pulling from database
    
    func getData() {
        
        // Get a reference to the database
        let db = Firestore.firestore()
            
        // Get current user ID
        let userId = Auth.auth().currentUser!.uid
        
        // Getting the data to show workouts
        // Path (users/uid/workouts/nameOfWorkout/workoutExercises/nameOfExercise/data)
        db.collection("users").document("\(userId)").collection("Workouts").getDocuments { (snapshot, error) in
            
            if let error = error {
                print(error)
                }
                else {
                
                    for document in snapshot!.documents {
                        
                        let workout = Workouts()
                        workout.name = document.documentID
                        self.workouts.append(workout)
                        
                        // Reloading the data so it can be displayed
                        self.tableView.reloadData()
                }
            }
        }
    }
    // MARK: - Logic help
    
    @IBAction func AddWorkoutTapped(_ sender: Any) {
        
        // Sets variable for the workout to be true
        addWorkOutTapped = true
    }
    
    
}

// Says the viewcontroller conforms to the HomeCellDelegate protocol, we can get the name this way
extension HomeViewController: HomeCellDelegate {
    func didTapEdit(name: String) {
        
        StructVariables.globalVariables.nameOfWorkout = name
        
    }
}
