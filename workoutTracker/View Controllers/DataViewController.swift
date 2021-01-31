//
//  DataViewController.swift
//  workoutTracker
//
//  Created by Hayden jin on 2021-01-27.
//  Copyright © 2021 Hayden jin. All rights reserved.
//

import UIKit
import Charts

class DataViewController: UIViewController {
    
    

    @IBOutlet weak var lineChart: LineChartView!
    
    
    var testArray = [1,2,3,4,5,6,7,8,9,10].map{Double($0)}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateGraph()
    }
    
    func updateGraph() {
        
        // Data set for the chart
        var lineChartset = [ChartDataEntry]()
        
        
        for i in 0...testArray.count - 1 {
            // Changes each value in the array into a data point
            let value = ChartDataEntry(x: Double(i), y: testArray[i])
            
            // Adds it into the chart
            lineChartset.append(value)
        }
        
        // Creates one line
        let line1 = LineChartDataSet(entries: lineChartset, label: "Number")
        
        // Sets the line color to blue
        line1.colors = [NSUIColor.blue]
        
        let data = LineChartData()
        
        data.addDataSet(line1)
        
        self.lineChart.data = data
    }
    
}