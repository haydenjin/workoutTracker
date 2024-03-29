//
//  ExerciseTableViewCell.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-08-12.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

// Protocol so we know which row was tapped for the button
protocol ExerciseCellDelegate {
    
    func deleteTapped(set: String)
    
}

class ExerciseTableViewCell: UITableViewCell, UITextFieldDelegate {

    // Empty variable for exercise
    var exercise:Exercises?
    
    // variable for the delegate
    var delegate: ExerciseCellDelegate?
    
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
    
  
    // Formats the cell
    func formatCell() {
        
        formatTextField(reps)
        formatTextField(weight)
        
        Utilities.addDoneButtonOnKeyboard(reps)
        Utilities.addDoneButtonOnKeyboard(weight)
        
    }

    // Setting the cell up
    func getNewInfo(_ e:Exercises) {
        
        // Set itself to the exercise
        self.exercise = e
        
        // Make sure we have an exercise
        guard self.exercise != nil else {
            return
        }
        
        let counter2 = StructVariables.count2
        
        // Force unwraps value and sets it as a Int
        exercise!.sets[counter2].reps = Int(self.reps.text!) ?? 0
        exercise!.sets[counter2].weights = Float(self.weight.text!) ?? 0
        
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
    
    @IBAction func didTapDelete(_ sender: Any) {
        delegate?.deleteTapped(set: setNum.text!)
    }
    
}
