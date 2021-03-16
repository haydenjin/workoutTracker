//
//  DataInputViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-03-13.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import Firebase

class DataInputViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var weight: UITextField!
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
    var exerciseNames = [String]()
    
    var selectedExercise = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getExerciseNames()
        
        if exerciseNames.count > 0 {
            //Set a default value for selected
            selectedExercise = exerciseNames[0]
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    // MARK:- Exercise picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return exerciseNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return exerciseNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        
        let selectedNumber = Int(row.description)!
        
        selectedExercise = exerciseNames[selectedNumber]
    }
    
    
    func getExerciseNames() {
        
        for exercise in 0...Master.exercises.count-1 {
            
            exerciseNames.append(Master.exercises[exercise].name)
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // Getting the current date
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let date = df.string(from: datePicker.date)
            
        let workout = db.collection("users").document("\(userId)").collection("UserInputData").document("OneRepMax")
        
        workout.setData(["Set": "Not virtual"])
        
        workout.collection(selectedExercise).document(date).setData(["Set": "Not virtual"], merge: true)
        
        workout.collection(selectedExercise).document(date).setData(["Date": date], merge: true)
        
        workout.collection(selectedExercise).document(date).setData(["Weight": weight.text ?? 0], merge: true)
        
    }
}
