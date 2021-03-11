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
    
    var testArray2: [ChartDataEntry] = [ChartDataEntry(x: 0.0, y: 275.0),ChartDataEntry(x: 1.0, y: 275.0),ChartDataEntry(x: 2.0, y: 280.0),ChartDataEntry(x: 3.0, y: 285.0),ChartDataEntry(x: 4.0, y: 275.0),ChartDataEntry(x: 5.0, y: 290.0),ChartDataEntry(x: 6.0, y: 295.0)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exerciseLabel.text = exerciseName

        updateGraph()
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
        
        /*
        // Data set for the chart
        var lineChartset = [ChartDataEntry]()
        
        
        for i in 0...testArray.count - 1 {
            // Changes each value in the array into a data point
            let value = ChartDataEntry(x: Double(i), y: testArray[i])
            
            // Adds it into the chart
            lineChartset.append(value)
        }
        */
        // Creates line that connects the dots
        let line1 = LineChartDataSet(entries: testArray2, label: "Number")
        
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
        
        // Setting the x-axis
        /*
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dateRange)
        lineChart.xAxis.granularity = 1
        */
        self.lineChart.data = data
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print(entry)
    }
    
    @IBAction func selectionDidChange(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            chartType.text = "Total Volume"
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
            updateGraph()
        }
    }
    
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
    
    func getSelectedData() {
        
        db.collection("users").document("\(userId)").collection("ExerciseData").document("AllExercises").collection(exerciseName).order(by: "Date", descending: true).getDocuments() { (querySnapshot, err) in
            if err != nil {
                // Error
            } else {
                // Query returns a list of dates for the selected exercise
                
                for document in querySnapshot!.documents {
                    
                    /*
                    // Sets the date (mostRecent) as the document ID
                    self.mostRecent = document.documentID
                    
                    // There are records, pull the most recent one
                    self.repsAndWeightsUpdate(workoutName: workoutName, workoutArrayIndex: workoutArrayIndex, exerciseName: exerciseName, exerciseArrayIndex: exerciseArrayIndex, exercise: exercise)
 
 */
                }
            }
        }
    }
}
