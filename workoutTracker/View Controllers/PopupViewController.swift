//
//  PopupViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class PopupViewController: UIViewController {
    
    @IBOutlet weak var nameOfExercise: UITextField!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var numberOfSets: UITextField!
    @IBOutlet weak var numberOfReps: UITextField!
    @IBOutlet weak var weight: UITextField!
    
    // Button user clicks when they are done making the exercise
    @IBAction func addExerciseTapped(_ sender: Any) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Create some variables
        let name = nameOfExercise.text
        let exerciseNotes = notes.text
        let sets = numberOfSets.text
        let reps = numberOfReps.text
        let weightNumber = weight.text
        
        // Get current user ID
        let userId = Auth.auth().currentUser!.uid
        
        // Add a new document to the users file
        db.collection("users").document("\(userId)").setData(["Name": name!, "Notes": exerciseNotes!, "Sets": sets!, "Reps": reps!, "Weight": weightNumber!,], merge: true)
        
        // Move back to the prev screen
        self.dismiss(animated: true, completion: nil)
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Get a reference to the database
        //let db = Firestore.firestore()
        
        // Adding a new document for the new exercise
        //db.collection("users").addDocument(data: ["name":"squat", "weight":245, "reps":8, "notes":"N/A"])
        
        // Creating a new document and keeping a variable that references the document
        //let newDoc = db.collection("users").document()
        
        // Overides the information in the referenced document, other options avalible too (Merge, etc)
        // "id" is storing the id of this document, is retrived by newDoc.documentID
        //newDoc.setData(["test":12, "test2":"tdee", "id":newDoc.documentID])
        
        // Creating a document with a specific document id
        //db.collection("users").document("Hayden's-workouts").setData(["bench":300, "squat":800])
        
        // Deleting a document
        //db.collection("users")
    }
}
