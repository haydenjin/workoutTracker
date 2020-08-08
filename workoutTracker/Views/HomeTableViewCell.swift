//
//  HomeTableViewCell.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-28.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

// Protocol so we know which row was tapped for the button
protocol HomeCellDelegate {
    
    func didTapEdit(name: String)
    
}


class HomeTableViewCell: UITableViewCell {

    
    @IBOutlet weak var workoutName: UILabel!
    
    // Empty variable for the workout
    var workout:Workouts?
    
    // variable for the delegate
    var delegate: HomeCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Setting the cell up
    func setCell(_ w:Workouts) {
        
        // Set itself to the exercise
        self.workout = w
        
        // Make sure we have an exercise
        guard self.workout != nil else {
            return
        }
        
        // Start setting the fields
        self.workoutName.text = workout?.name
        
    }
    
    // Connection to the button, sends the name of the workout in this case
    @IBAction func editTapped(_ sender: Any) {
        delegate?.didTapEdit(name: workout!.name)
    }
}
