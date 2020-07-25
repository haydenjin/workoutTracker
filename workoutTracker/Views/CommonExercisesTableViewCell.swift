//
//  CommonExercisesTableViewCell.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-23.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class CommonExercisesTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var weights: UITextField!
    @IBOutlet weak var reps: UITextField!
    @IBOutlet weak var sets: UITextField!
    
    // Empty variable for the exercise this cell will display
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
        self.name.text = exercise?.name
        self.weights.text = String(exercise!.weight)
        self.reps.text = String(exercise!.reps)
        self.sets.text = String(exercise!.sets)
        
    }
}
