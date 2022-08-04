//
//  RepSummarySlide.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/16/22.
//

import UIKit
import Charts

class RepSummarySlide: UIView {
    
    @IBOutlet weak var velocityGraphView: LineChartView!
    @IBOutlet weak var powerGraphView: LineChartView!
    @IBOutlet weak var repNumberTitle: UILabel!
    @IBOutlet weak var repAverageVelocity: UILabel!
    @IBOutlet weak var repMaxVelocity: UILabel!
    @IBOutlet weak var repAveragePower: UILabel!
    @IBOutlet weak var repMaxPower: UILabel!
    @IBOutlet weak var projectedORM: UILabel!
    @IBOutlet weak var repTTP: UILabel!
    
}
