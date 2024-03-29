//
//  ActiveWorkoutTableViewCell.swift
//  workoutTracker
//
//  Created by Hayden jin on 2020-07-29.
//  Copyright © 2020 Hayden jin. All rights reserved.
//

import UIKit

class ActiveWorkoutTableViewCell: UITableViewCell {

    // Empty variable for exercise
    var exercise:Exercises?
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var checkMarkImage: UIButton!
    
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
        self.name.text = exercise!.name
        
        if Master.workoutCheck.count > 0 {
            
            for i in 0...Master.workoutCheck.count - 1 {
                if Master.workoutCheck[i].name == exercise!.name && Master.workoutCheck[i].done == true {
                    
                    self.checkMarkImage.alpha = 1
                }
            }
        }
    }
}
