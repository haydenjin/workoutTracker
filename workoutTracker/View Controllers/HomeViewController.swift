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
    
    
    // An array of Workouts which is empty at first
    var workouts = [Workouts]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData(completion: nil)
        
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
    
    // Returns the number of global workouts
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Picking what cell displays this data
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeCell", for: indexPath) as! HomeTableViewCell
        
        // Configure cell with data with the object in each array slot
        let workout = self.workouts[indexPath.row]
        
        cell.setCell(workout)
        
        // Return the cell
        return cell
    }


    // MARK: - Reciving Information

        // Gets the data from the Popup screen
        @IBAction func unwindToHome(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? AddWorkoutViewController {
            
            // Copying the data from the other viewcontroller and combining (Merging) the arrays
            workouts += sourceViewController.workoutsArray
        }
    }
    
    
    func getData(completion: @escaping (Error?) -> Void) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
            
        // Get current user ID
        let userId = Auth.auth().currentUser!.uid
        
        // Getting the data to show workouts
        // Path (users/uid/workouts/nameOfWorkout/nameOfExercise/nameOfExercise/data
        db.collection("users").document("\(userId)").collection("Workouts").getDocuments { (snapshot, error) in
            
            if let error = error {
                print(error)
                }
                else {
                
                    for document in snapshot!.documents {
                        
                        print("Data: \(document.documentID)")
                        let workout = Workouts()
                        workout.name = document.documentID
                        self.workouts.append(workout)
                }
            }
        }
        completion(nil)
    }
}
