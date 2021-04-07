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
    
    var chartPointsTimeline: [ChartDataEntry] = []
    
    var exerciseIndex = 0
    
    var numOfSets = 0
    
    // MARK:- View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        // Clear previous memoryv
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
        
        // Lets getSelectedDates finish running before function is ran
        let seconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.defaultSetup()
        }
    }
    
    // MARK:- Update Graph
    func updateGraph() {
        
        // Setting the back ground color
        lineChart.backgroundColor = .white//UIColor(red: 235/255, green: 239/255, blue: 242/255, alpha: 1) //Shade of gray
        
        // Removing right Y axis
        lineChart.rightAxis.enabled = false
        
        lineChart.legend.enabled = false
        
        lineChart.xAxis.drawGridLinesEnabled = false
        
        // Modifying left Y axis
        let yAxis = lineChart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.labelTextColor = .black
        yAxis.axisLineColor = .black
        yAxis.granularity = 1
        yAxis.axisLineWidth = 3
        yAxis.drawGridLinesEnabled = false
        
        // Moving label down to bottom
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.axisLineColor = .black
        yAxis.labelTextColor = .black
        xAxis.valueFormatter = ChartXAxisFormatter()
        xAxis.setLabelCount(dataSet.count, force: true)
        xAxis.granularity = 1
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.axisLineWidth = 3
        
        // Animate the movement
        lineChart.animate(xAxisDuration: 0.5)
        
        // Creates line that connects the dots
        let line1 = LineChartDataSet(entries: chartPoints, label: "Number")
        
        // Customizing the lines
        line1.circleRadius = 6
        line1.setCircleColors(.purple)
        line1.setColor(.black)
        line1.circleHoleColor = UIColor(red: 175/255, green: 248/255, blue: 219/255, alpha: 1)
        line1.mode = .horizontalBezier
        line1.lineWidth = 3
        line1.setColor(.black)
        line1.drawHorizontalHighlightIndicatorEnabled = false
        line1.drawVerticalHighlightIndicatorEnabled = false
        
        let data = LineChartData()
        
        data.setValueTextColor(.black)
        
        data.addDataSet(line1)
        
        self.lineChart.data = data
    }
    
    func updateGraph2() {
        
        // Setting the back ground color
        lineChart.backgroundColor = .white//UIColor(red: 235/255, green: 239/255, blue: 242/255, alpha: 1) //Shade of gray
        
        // Removing right Y axis
        lineChart.rightAxis.enabled = false
        
        lineChart.legend.enabled = false
        
        // Modifying left Y axis
        let yAxis = lineChart.leftAxis
        yAxis.labelFont = .boldSystemFont(ofSize: 12)
        yAxis.labelTextColor = .black
        yAxis.axisLineColor = .black
        yAxis.granularity = 1
        yAxis.axisLineWidth = 3
        
        // Moving label down to bottom
        let xAxis = lineChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .boldSystemFont(ofSize: 12)
        xAxis.axisLineColor = .black
        yAxis.labelTextColor = .black
        xAxis.valueFormatter = ChartXAxisFormatter()
        xAxis.setLabelCount(dataSet.count, force: true)
        xAxis.granularity = 1
        xAxis.avoidFirstLastClippingEnabled = true
        xAxis.axisLineWidth = 3
        
        // Animate the movement
        lineChart.animate(xAxisDuration: 0.5)
        
        // Creates line that connects the dots
        let line1 = LineChartDataSet(entries: chartPointsTimeline, label: "Number")
        
        // Customizing the lines
        line1.circleRadius = 6
        line1.setCircleColors(.purple)
        line1.setColor(.black)
        line1.circleHoleColor = UIColor(red: 175/255, green: 248/255, blue: 219/255, alpha: 1)
        line1.mode = .horizontalBezier
        line1.lineWidth = 3
        line1.setColor(.black)
        line1.drawHorizontalHighlightIndicatorEnabled = false
        line1.drawVerticalHighlightIndicatorEnabled = false
        
        let data = LineChartData()
        
        data.setValueTextColor(.black)
        
        data.addDataSet(line1)
        
        self.lineChart.data = data
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
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let date = dateFormatter.date(from: dataSet[i].date)!
                    
                    let calender = Calendar.current
                    let components = calender.dateComponents([.year, .month, .day], from: date)
                    
                    let finalDate = calender.date(from: components)!.timeIntervalSince1970
                    
                    let value = ChartDataEntry(x: Double(finalDate), y: Double(totalVolume))
                    
                    
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
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let date = dateFormatter.date(from: dataSet[i].date)!
                    
                    let calender = Calendar.current
                    let components = calender.dateComponents([.year, .month, .day], from: date)
                    
                    let finalDate = calender.date(from: components)!.timeIntervalSince1970
                    
                    let value = ChartDataEntry(x: Double(finalDate), y: Double(aveWeight))
                    
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
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let date = dateFormatter.date(from: dataSet[i].date)!
                    
                    let calender = Calendar.current
                    let components = calender.dateComponents([.year, .month, .day], from: date)
                    
                    let finalDate = calender.date(from: components)!.timeIntervalSince1970
                    
                    let value = ChartDataEntry(x: Double(finalDate), y: Double(aveReps))
                    
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
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let date = dateFormatter.date(from: oneRPDataSet[i].date)!
                    
                    let calender = Calendar.current
                    let components = calender.dateComponents([.year, .month, .day], from: date)
                    
                    let finalDate = calender.date(from: components)!.timeIntervalSince1970
                    
                    let value = ChartDataEntry(x: Double(finalDate), y: Double(oneRPDataSet[i].weight))
                    
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
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    let date = dateFormatter.date(from: dataSet[i].date)!
                    
                    let calender = Calendar.current
                    let components = calender.dateComponents([.year, .month, .day], from: date)
                    
                    let finalDate = calender.date(from: components)!.timeIntervalSince1970
                    
                    let value = ChartDataEntry(x: Double(finalDate), y: Double(totalVolume))
                    
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
            
            if chartPoints.count == 0 {
                viewDidLoad()
            }
            
            guard chartPoints.count != 0 else {
                break
            }
            
            chartPointsTimeline.removeAll()
            
            var total = chartPoints.count - 1
            
            if total >= 6 {
                total = 6
            }
            
            for i in 0...total {
                chartPointsTimeline.append(chartPoints[i])
            }
            
            updateGraph2()
        case 1:
            dateLabel.text = "Monthly"
            
            if chartPoints.count == 0 {
                viewDidLoad()
            }
            
            guard chartPoints.count != 0 else {
                break
            }
            
            chartPointsTimeline.removeAll()
            
            var total = chartPoints.count - 1
            
            if total >= 29 {
                total = 29
            }
            
            for i in 0...total {
                chartPointsTimeline.append(chartPoints[i])
            }
            
            updateGraph2()
        case 2:
            dateLabel.text = "Yearly"
            
            if chartPoints.count == 0 {
                viewDidLoad()
            }
            
            guard chartPoints.count != 0 else {
                break
            }
            
            chartPointsTimeline.removeAll()
            
            var total = chartPoints.count - 1
            
            if total >= 364 {
                total = 364
            }
            
            for i in 0...total {
                chartPointsTimeline.append(chartPoints[i])
            }
            
            updateGraph2()
        case 3:
            dateLabel.text = "All time"
            
            if chartPoints.count == 0 {
                viewDidLoad()
            }
            
            guard chartPoints.count != 0 else {
                break
            }
            
            chartPointsTimeline.removeAll()
            
            let total = chartPoints.count - 1
            
            for i in 0...total {
                chartPointsTimeline.append(chartPoints[i])
            }
            
            updateGraph2()
        default:
            dateLabel.text = "Weekly"
            
            if chartPoints.count == 0 {
                viewDidLoad()
            }
            
            guard chartPoints.count != 0 else {
                break
            }
            
            chartPointsTimeline.removeAll()
            
            var total = chartPoints.count - 1
            
            if total >= 6 {
                total = 6
            }
            
            for i in 0...total {
                chartPointsTimeline.append(chartPoints[i])
            }
            
            updateGraph2()
            
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
        
        if dataSet.count > 0 {
            
            // For each data point
            for i in 0...dataSet.count-1 {
                
                // Makes sure there is no empty array
                guard dataSet[i].repsArray.count != 0 else {
                    return
                }
                
                // Calculates the data value
                for sets in 0...dataSet[i].repsArray.count-1 {
                    
                    // Makes sure there is no empty array
                    guard dataSet[i].weightsArray.count != 0 else {
                        return
                    }
                    
                    let calc = Float(dataSet[i].repsArray[sets]) * dataSet[i].weightsArray[sets]
                    
                    totalVolume = totalVolume + calc
                    
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd"
                
                let date = dateFormatter.date(from: dataSet[i].date)!
                
                let calender = Calendar.current
                let components = calender.dateComponents([.year, .month, .day], from: date)
                
                let finalDate = calender.date(from: components)!.timeIntervalSince1970
                
                let value = ChartDataEntry(x: Double(finalDate), y: Double(totalVolume))
                
                // Adds it into the chart
                chartPoints.append(value)
                
                // Reset the value
                totalVolume = 0
                
            }
            
        }
        
        updateGraph()
    }
    
    // MARK: - Chart date format
    
    class ChartXAxisFormatter: NSObject, IAxisValueFormatter {

        func stringForValue(_ value: Double, axis: AxisBase?) -> String {

            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("MM/dd")
            dateFormatter.locale = .current

            let date = Date(timeIntervalSince1970: value)

            return dateFormatter.string(from: date)
        }
    }
}
