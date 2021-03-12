//
//  DataViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-01-27.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import Firebase
import Charts

class DataViewController: UIViewController, ChartViewDelegate {
    
    // Get a reference to the database
    let db = Firestore.firestore()
    
    // Get current user ID
    let userId = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var exerciseLabel: UILabel!
    
    @IBOutlet weak var chartType: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var lineChart: LineChartView!
    
    var exerciseName = ""
    
    var testArray = [1,2,3,4,5,6,7,8,9,10,11,12].map{Double($0)}
    
    var aveVolumeArray = [Double]()
    
    var dateRange = [String]()
    
    var returnedExercises = [String]()
    
    // Data set structure
    struct dataSetStruct {
        
        var date = ""
        
        var repsArray = [Int]()
        
        var weightsArray = [Float]()
    }
    
    // Main Data set
    var dataSet = [dataSetStruct]()
    
    var chartPoints: [ChartDataEntry] = [ChartDataEntry(x: 0.0, y: 275.0),ChartDataEntry(x: 1.0, y: 275.0),ChartDataEntry(x: 2.0, y: 280.0),ChartDataEntry(x: 3.0, y: 285.0),ChartDataEntry(x: 4.0, y: 275.0),ChartDataEntry(x: 5.0, y: 290.0),ChartDataEntry(x: 6.0, y: 295.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseLabel.text = exerciseName
        
        getSelectedDates()
        
    }
    
    func updateGraph() {
        
        // Setting the back ground color
        lineChart.backgroundColor = .lightGray
        
        // Removing right axis
        lineChart.rightAxis.enabled = false
        
        // Modifying left axis
        let yAxis = lineChart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.setLabelCount(6, force: false)
        yAxis.axisLineColor = .black
        
        // Moving label down to bottom
        
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.labelFont = .boldSystemFont(ofSize: 12)
        lineChart.xAxis.setLabelCount(6, force: false)
        lineChart.xAxis.axisLineColor = .black
        
        // Animate the movement
        lineChart.animate(xAxisDuration: 0.5)
        
        // Creates line that connects the dots
        let line1 = LineChartDataSet(entries: chartPoints, label: "Number")
        
        // Sets the line color to blue
        line1.colors = [NSUIColor.blue]
        
        // Customizing the lines
        line1.circleRadius = 3
        line1.mode = .horizontalBezier
        line1.lineWidth = 3
        line1.setColor(.green)
        line1.drawHorizontalHighlightIndicatorEnabled = false
        line1.drawVerticalHighlightIndicatorEnabled = false
        
        let data = LineChartData()
        
        data.addDataSet(line1)
        
        self.lineChart.data = data
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    // MARK: - Data select
    
    @IBAction func selectionDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            chartType.text = "Total Volume"
            
            // Update the array of chart points
            chartPoints.removeAll()
            
            // Calculate the max volume
            var totalVolume:Float = 0
            
            // For each data point
            for i in 0...dataSet.count-1 {
                
                // Calculates the data value
                for sets in 0...dataSet[i].repsArray.count-1 {
                    
                    let calc = Float(dataSet[i].repsArray[sets]) * dataSet[i].weightsArray[sets]
                    
                    totalVolume = totalVolume + calc
                    
                }
                
                let value = ChartDataEntry(x: Double(dataSet[i].date) ?? Double(i), y: Double(totalVolume))
                
                // Adds it into the chart
                chartPoints.append(value)
                
                // Reset the value
                totalVolume = 0
                
            }
            
            updateGraph()
        case 1:
            chartType.text = "Average Weight"
            updateGraph()
        case 2:
            chartType.text = "Average reps"
            updateGraph()
        case 3:
            chartType.text = "One Rep Max"
            updateGraph()
        default:
            chartType.text = "Total Volume"
            
            // Update the array of chart points
            chartPoints.removeAll()
            
            // Calculate the max volume
            var totalVolume:Float = 0
            
            // For each data point
            for i in 0...dataSet.count-1 {
                
                // Calculates the data value
                for sets in 0...dataSet[i].repsArray.count-1 {
                    
                    let calc = Float(dataSet[i].repsArray[sets]) * dataSet[i].weightsArray[sets]
                    
                    totalVolume = totalVolume + calc
                    
                }
                
                let value = ChartDataEntry(x: Double(dataSet[i].date) ?? Double(i), y: Double(totalVolume))
                
                // Adds it into the chart
                chartPoints.append(value)
                
                // Reset the value
                totalVolume = 0
                
            }
            
            updateGraph()
        }
    }
    
    // MARK: - Time select
    
    @IBAction func timeRangeDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            dateLabel.text = "Weekly"
            /*
             // Change the range to last 7 days
             // Getting the current date
             let df = DateFormatter()
             df.dateFormat = "dd"
             var currDate = df.string(from: Date())
             
             var startDate = Int(currDate)! - 7
             
             dateRange.removeAll()
             
             for startDate in 1...7 {
             dateRange.append(startDate)
             startDate = startDate + 1
             }
             */
            updateGraph()
        case 1:
            dateLabel.text = "Monthly"
            updateGraph()
        case 2:
            dateLabel.text = "Yearly"
            updateGraph()
        case 3:
            dateLabel.text = "All time"
            updateGraph()
        default:
            dateLabel.text = "Weekly"
            updateGraph()
        }
    }
    
    func getSelectedDates() {
        
        db.collection("users").document("\(userId)").collection("ExerciseData").document("AllExercises").collection(exerciseName).order(by: "Date", descending: false).getDocuments() { (querySnapshot, err) in
            if err != nil {
                // Error
            } else {
                // Query returns a list of dates for the selected exercise
                
                for document in querySnapshot!.documents {
                    
                    let data:[String:Any] = document.data()
                    
                    let date = data["Date"] as! String
                    
                    self.returnedExercises.append(date)
                }
                self.getSelectedData()
            }
        }
    }
    
    func getSelectedData() {
        
        var exerciseIndex = 0
        
        for i in 0...Master.exercises.count - 1 {
            if Master.exercises[i].name == self.exerciseName {
                exerciseIndex = i
            }
        }
        
        let numOfSets = Master.exercises[exerciseIndex].totalSets
        
        // For each date record
        for count in 0...self.returnedExercises.count-1 {
            
            // Creates a new dataSet
            dataSet.append(dataSetStruct())
            
            dataSet[count].date = returnedExercises[count]
            
            for number in 0...(numOfSets - 1) {
                
                // Retrives the reps
                let repsDbCallHistory = db.collection("users").document("\(userId)").collection("ExerciseData").document("AllExercises").collection(exerciseName).document(returnedExercises[count]).collection("Set\(number + 1)").document("reps")
                
                repsDbCallHistory.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // For every document (Set) in the database, copy the values and add them to the array
                        
                        let data:[String:Any] = document.data()!
                        
                        self.dataSet[count].repsArray.append(data["Reps\(number + 1)"] as! Int)
                    }
                    else {
                        // error
                    }
                }
                
                //Retrives the weights
                let weightsDbCallHistory = db.collection("users").document("\(userId)").collection("ExerciseData").document("AllExercises").collection(exerciseName).document(returnedExercises[count]).collection("Set\(number + 1)").document("weights")
                
                weightsDbCallHistory.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // For every document (Set) in the database, copy the values and add them to the array
                        
                        let data:[String:Any] = document.data()!
                        
                        self.dataSet[count].weightsArray.append(data["Weight\(number + 1)"] as! Float)
                        
                        self.updateGraph()
                    }
                    else {
                        // error
                    }
                }
            }
        }
    }
}
