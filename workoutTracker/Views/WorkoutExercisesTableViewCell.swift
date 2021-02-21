//
//  WorkoutExercisesTableViewCell.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-25.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

// Protocol so we know which row was tapped for the button
protocol WorkoutCellDelegate {
    
    func didTapDelete(name: String)
    
    func didTapEdit(name: String)
    
}

class WorkoutExercisesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var nameLabel: UILabel!
    
    // Variable for this cell to display
    var exercise:Exercises?
    
    // variable for the delegate
    var delegate: WorkoutCellDelegate?

    
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
    }

    // Connection to the button, sends the name of the exercise in this case
    @IBAction func deleteTapped(_ sender: Any) {
        delegate?.didTapDelete(name: exercise!.name)
    }
    
    @IBAction func editTapped(_ sender: Any) {
        delegate?.didTapEdit(name: exercise!.name)
    }
    
}
