//
//  WorkoutExercisesTableViewCell.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-25.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class WorkoutExercisesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sets: UITextField!
    @IBOutlet weak var reps: UITextField!
    @IBOutlet weak var weight: UITextField!
    
    // Variable for this cell to display
    var exercise:Exercises?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Setting the cell up
    func setCell(_ e:Exercises) {
        
        // Set itself to the exercise
        self.exercise = e
        
        // Make sure we have an exercise
        guard self.exercise != nil else {
            return
        }
        
        // Start setting the fields
        self.nameLabel.text = exercise?.name
        self.weight.text = String(exercise!.weights)
        self.reps.text = String(exercise!.reps)
        self.sets.text = String(exercise!.sets)
        
    }

}
