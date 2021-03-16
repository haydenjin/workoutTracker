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
    
    var returnedExercises = [String]()
    
    var returnedOneRepMax = [String]()
    
    // Data set structure
    struct dataSetStruct {
        
        var date = ""
        
        var repsArray = [Int]()
        
        var weightsArray = [Float]()
    }
    
    // Data set structure
    struct oneRepMaxStruct {
        
        var date = ""
        
        var weight = Float(0.0)
    }
    
    // Main Data set
    var dataSet = [dataSetStruct]()
    
    // One Rep Max set
    var oneRPDataSet = [oneRepMaxStruct]()
    
    var chartPoints: [ChartDataEntry] = []
    
    var exerciseIndex = 0
    
    var numOfSets = 0
    
    // MARK:- View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Clear previous memory
        oneRPDataSet.removeAll()
        dataSet.removeAll()
        
        exerciseLabel.text = exerciseName
        
        for i in 0...Master.exercises.count - 1 {
            if Master.exercises[i].name == self.exerciseName {
                exerciseIndex = i
            }
        }
        
        numOfSets = Master.exercises[exerciseIndex].totalSets
        
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
            
            if dataSet.count > 0 {
                
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
            }
            
            updateGraph()
            
        case 1:
            chartType.text = "Average Weight"
            
            // Update the array of chart points
            chartPoints.removeAll()
            
            // Calculate the max volume
            var aveWeight:Float = 0
            
            if dataSet.count > 0 {
                
                // For each data point
                for i in 0...dataSet.count-1 {
                    
                    // Calculates the data value
                    for sets in 0...dataSet[i].repsArray.count-1 {
                        
                        aveWeight = aveWeight + dataSet[i].weightsArray[sets]
                        
                    }
                    
                    aveWeight = (aveWeight / Float(dataSet[i].repsArray.count))
                    
                    let value = ChartDataEntry(x: Double(dataSet[i].date) ?? Double(i), y: Double(aveWeight))
                    
                    // Adds it into the chart
                    chartPoints.append(value)
                    
                    // Reset the value
                    aveWeight = 0
                    
                }
            }
            
            updateGraph()
            
        case 2:
            chartType.text = "Average reps"
            
            // Update the array of chart points
            chartPoints.removeAll()
            
            // Calculate the max volume
            var aveReps:Float = 0
            
            if dataSet.count > 0 {
                // For each data point
                for i in 0...dataSet.count-1 {
                    
                    // Calculates the data value
                    for sets in 0...dataSet[i].repsArray.count-1 {
                        
                        aveReps = aveReps + Float(dataSet[i].repsArray[sets])
                        
                    }
                    
                    aveReps = (aveReps / Float(dataSet[i].repsArray.count))
                    
                    let value = ChartDataEntry(x: Double(dataSet[i].date) ?? Double(i), y: Double(aveReps))
                    
                    // Adds it into the chart
                    chartPoints.append(value)
                    
                    // Reset the value
                    aveReps = 0
                    
                }
            }
            
            updateGraph()
            
        case 3:
            chartType.text = "One Rep Max"
            
            // Update the array of chart points
            chartPoints.removeAll()
            
            if oneRPDataSet.count > 0 {
                
                // For each data point
                for i in 0...oneRPDataSet.count-1 {
                    
                    let value = ChartDataEntry(x: Double(oneRPDataSet[i].date) ?? Double(i), y: Double(oneRPDataSet[i].weight))
                    
                    // Adds it into the chart
                    chartPoints.append(value)
                    
                }
            }
            
            updateGraph()
            
        default:
            chartType.text = "Total Volume"
            
            // Update the array of chart points
            chartPoints.removeAll()
            
            if dataSet.count > 0 {
                
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
    
    // MARK: - Getting data
    
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
        
        db.collection("users").document("\(userId)").collection("UserInputData").document("OneRepMax").collection(exerciseName).order(by: "Date", descending: false).getDocuments() { (querySnapshot, err) in
            if err != nil {
                // Error
            } else {
                // Query returns a list of dates for the selected exercise
                
                for document in querySnapshot!.documents {
                    
                    let data:[String:Any] = document.data()
                    
                    let date = data["Date"] as! String
                    
                    self.returnedOneRepMax.append(date)
                }
                self.getOneRepMax(completion: { message in
                       print(message)
                })
                
                print("Finished getting data")
            }
        }
    }
    
    func getSelectedData() {
        
        if returnedExercises.count > 0 {
            
            // For each date record
            for count in 0...self.returnedExercises.count-1 {
                
                // Creates a new dataSet
                self.dataSet.append(dataSetStruct())
                
                self.dataSet[count].date = self.returnedExercises[count]
                
                for number in 0...(self.numOfSets - 1) {
                    
                    // Retrives the reps
                    let repsDbCallHistory = self.db.collection("users").document("\(self.userId)").collection("ExerciseData").document("AllExercises").collection(self.exerciseName).document(self.returnedExercises[count]).collection("Set\(number + 1)").document("reps")
                    
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
                    let weightsDbCallHistory = self.db.collection("users").document("\(self.userId)").collection("ExerciseData").document("AllExercises").collection(self.exerciseName).document(self.returnedExercises[count]).collection("Set\(number + 1)").document("weights")
                    
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
    
    func getOneRepMax(completion: @escaping (_ message: String) -> Void) {
        
        if returnedOneRepMax.count > 0 {
            
            print("Getting Data")
            
            // For each date record
            for count in 0...self.returnedOneRepMax.count-1 {
                
                // Creates a new dataSet
                oneRPDataSet.append(oneRepMaxStruct())
                
                oneRPDataSet[count].date = returnedOneRepMax[count]
                
                // Retrives the reps
                let oneRepMax = db.collection("users").document("\(userId)").collection("UserInputData").document("OneRepMax").collection(exerciseName).document(returnedOneRepMax[count])
                
                oneRepMax.getDocument { (document, error) in
                    if let document = document, document.exists {
                        // For every document (Set) in the database, copy the values and add them to the array
                        
                        let data:[String:Any] = document.data()!
                        
                        self.oneRPDataSet[count].weight = Float(data["Weight"] as! String)!
                        
                        print("Getting data: \(count)")
                        
                        completion("DONE")
                        
                        self.updateGraph()
                    }
                    else {
                        // error
                    }
                }
            }
        }
    }
    
    // MARK: - Default screen setup
    
    func defaultSetup() {
        
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
