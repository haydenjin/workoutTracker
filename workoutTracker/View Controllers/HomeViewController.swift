//
//  FirstViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-16.
//  Copyright © 2020 Hayden jin. All rights reserved.
//


// Uncomment out functions when ready

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate /*UITableViewDataSource*/ {


    @IBOutlet weak var AddNewWorkout: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func logoutTapped(_ sender: Any) {
        AppManager.shared.logout()
    }
    
    
    // An array of WorkoutsGlobal which is empty at first
    var workoutsGlobal = [WorkoutsGlobal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assigning the FirstViewController as the datasource of the tableview
        //tableView.dataSource = self
        
        // Assigning the FirstViewController as the delegate of the tableview
        tableView.delegate = self
        
    }
    
    // Returns the number of global workouts
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workoutsGlobal.count
    }
    /*
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    }
    */
}
