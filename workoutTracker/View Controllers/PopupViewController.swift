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
    
    // MARK: - Connections & variables
    
    @IBOutlet weak var nameOfExercise: UITextField!
    @IBOutlet weak var notes: UITextField!
    @IBOutlet weak var numberOfSets: UITextField!
    @IBOutlet weak var numberOfReps: UITextField!
    @IBOutlet weak var weight: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    // Empty array of user added exercises, this array will only ever have max one exercise
    var exerciseArray = [Exercises]()
   
    // MARK: - Button is tapped
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
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
            let sets = Int(numberOfSets.text!)
            let reps = Int(numberOfReps.text!)
            let weightNumber = Int(weight.text!)
            
            // Get current user ID
            let userId = Auth.auth().currentUser!.uid
            
            // Add a new document to the users file
            db.collection("users").document("\(userId)").collection("exercises").document("\(name)").setData(["Name": name, "Notes": exerciseNotes!, "Sets": sets!, "Reps": reps!, "Weight": weightNumber!,], merge: true)
            
            // Transitioning the screen back to add exercise screen
            performSegue(withIdentifier: "unwindSegueToAddExercise", sender: self)
            
        }
    }
    
    // MARK: - Sending back information
    
    // Function needed to pass data back to a previous viewcontroller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Create some variables
        let name = nameOfExercise.text!
        let exerciseNotes = notes.text
        let sets = Int(numberOfSets.text!)
        let reps = Int(numberOfReps.text!)
        let weightNumber = Int(weight.text!)
        
        if name == "" {
            return
        }
        
        if (sets == nil) || (reps == nil) || (weightNumber == nil) {
            return
        }
        
        // Creating the exercise and saving it in the array
        let exercise = Exercises()
        exercise.addNewExercise(name: name, notes: exerciseNotes ?? "", weight: weightNumber!, reps: reps!, sets: sets!)
        exerciseArray.append(exercise)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // Makes it a number text field
        textfield.keyboardType = .numberPad
        
        // Set the return as (done)
        textfield.returnKeyType = .next
        
        // Center the screen on the text field when clicked
        textfield.center = self.view.center

    }
    
    // Function to drop down text field after its done being used
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
