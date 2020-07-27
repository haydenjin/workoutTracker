//
//  AddExerciseViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class AddExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    // Array of empty exercises
    var commonExercises = [Exercises]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        tableView.delegate = self

        addExercises()
    }
    
    // Function to add all common exercises
    func addExercises() {
        
        let backSquat = Exercises()
        backSquat.addNewExercise(name: "Back Squat", notes: "Try to keep knees behind your toes, lower till legs are parallel", weight: 145, reps: 6, sets: 3)
        commonExercises.append(backSquat)
        
        let benchPress = Exercises()
        benchPress.addNewExercise(name: "Bench Press", notes: "Lower bar until it touches your chest, then push back up until your arms are locked", weight: 145, reps: 6, sets: 3)
        commonExercises.append(benchPress)
    }
    
    // Asking for number of tables to display
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commonExercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Picking what cell displays this data
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonExercisesCell", for: indexPath) as! CommonExercisesTableViewCell
        
        // Configure cell with data with the object in each array slot
        let exercise = self.commonExercises[indexPath.row]
        
        cell.setCell(exercise)
        
        // Return the cell
        return cell
    }
}
