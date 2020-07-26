//
//  PopupViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-22.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit
import Firebase


class PopupViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameOfExercise: UITextField!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var numberOfSets: UITextField!
    @IBOutlet weak var numberOfReps: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Variable to get array we want
    var copiedExercisesArray: Array = Array<Any>()
    
    // MARK: - Button is tapped
    
    // Button user clicks when they are done making the exercise
    @IBAction func addExerciseTapped(_ sender: Any) {
        
        // Get a reference to the database
        let db = Firestore.firestore()
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            // There was an error
            // Change the error label and make it visible
            errorLabel.text = error
            errorLabel.alpha = 1
        }
        else {
            // Create some variables
            let name = nameOfExercise.text!
            let exerciseNotes = notes.text
            // Put a guard in place after
            let sets = Int(numberOfSets.text!)
            let reps = Int(numberOfReps.text!)
            let weightNumber = Int(weight.text!)
            
            // Get current user ID
            let userId = Auth.auth().currentUser!.uid
            
            // Add a new document to the users file
            db.collection("users").document("\(userId)").collection("exercises").document("\(name)").setData(["Name": name, "Notes": exerciseNotes!, "Sets": sets!, "Reps": reps!, "Weight": weightNumber!,], merge: true)
            
            // Creating the exercise and saving it in the array
            let exercise = UserAddedExercises()
            exercise.addExercises(name: name, notes: exerciseNotes ?? "", weight: weightNumber!, reps: reps!, sets: sets!)
            copiedExercisesArray.append(exercise)
            
            // Move back to the prev screen
            // setting the variable as the home view
            let addExercises = self.storyboard?.instantiateViewController(withIdentifier: "AddExercise")
            
            // Setting the user view as the homeVC
            self.view.window?.rootViewController = addExercises
            // Setting the current view and making it visible
            self.view.window?.makeKeyAndVisible()
            
            // Dismisses the window to go back one view
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Creating an object of the class in order to get the variables
        let copyArray: UserAddedExercisesArray = UserAddedExercisesArray()
        
        // Setting the variable to the array we want
        copiedExercisesArray = copyArray.workoutExercisesArray

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

    // MARK: - Validation
    
    // Checks if all required fields are filled out
    func validateFields() -> String? {
    
        // Check that all required fields are filled while removing white spaces and new lines
        if nameOfExercise.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            numberOfSets.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            weight.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            numberOfReps.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            // Fields not filled, Display error message
            return "Please fill in all fields"
            }
            // Fields are filled, keep going
            return nil
    }

    
    // MARK: - Field Formating functions
    
    // Formating the text fields
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        formatTextField(nameOfExercise)
        formatTextField(notes)
        formatNumberField(numberOfReps)
        formatNumberField(numberOfSets)
        formatNumberField(weight)
    }
    
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
    
    // Function to formate the text fields
    func formatNumberField(_ textField:UITextField) {
        
        // Create a variable
        let textfield = textField
        
        // Make itself the delegate
        textfield.delegate = self
        
        // Set the return as (done)
        textfield.returnKeyType = .done
        
        // Makes it a number text field
        textfield.keyboardType = .numberPad
        
        // Center the screen on the text field when clicked
        textfield.center = self.view.center

    }
    
    // Function to drop down text field after its done being used
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
