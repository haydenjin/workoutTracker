//
//  ExerciseTableViewCell.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-08-12.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell, UITextFieldDelegate {

    // Empty variable for exercise
    var exercise:Exercises.VariableExercises?
    
    @IBOutlet weak var setNum: UILabel!
    
    @IBOutlet weak var reps: UITextField!
    
    @IBOutlet weak var weight: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Setting the cell up
    func setCell(_ e:Exercises.VariableExercises) {
        
        // Set itself to the exercise
        self.exercise = e
        
        // Make sure we have an exercise
        guard self.exercise != nil else {
            return
        }
        
        // Start setting the fields
        self.setNum.text = "Set \(StructVariables.count + 1)"
        self.reps.text = "\(exercise!.reps[StructVariables.count])"
        self.weight.text = "\(exercise!.weights[StructVariables.count])"
        
        formatTextField(reps)
        formatTextField(weight)
        
        StructVariables.count += 1
    }
    
    // Setting the cell up
    func getNewInfo(_ e:Exercises.VariableExercises) {
        
        // Set itself to the exercise
        self.exercise = e
        
        // Make sure we have an exercise
        guard self.exercise != nil else {
            return
        }
        
        // Force unwraps value and sets it as a Int
        exercise!.reps[StructVariables.count2] = Int(self.reps.text!) ?? 0
        exercise!.weights[StructVariables.count2] = Int(self.weight.text!) ?? 0
        
        StructVariables.count2 += 1
    }
    
    // MARK: - Field Formating functions

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

    }
    
    // Function to drop down text field after its done being used
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
