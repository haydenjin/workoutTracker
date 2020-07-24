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
