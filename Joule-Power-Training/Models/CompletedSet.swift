//
//  CompletedSet.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/31/22.
//

import Foundation

class CompletedSet {
    let completedReps: [CompletedRep]
    var averageVelocityArray: [Int] = []
    var maxVelocityArray: [Int] = []
    var averagePowerArray: [Int] = []
    var maxPowerArray: [Int] = []
    var ttpArray: [Double] = []
    
    var averageVelocity: Int
    var maxVelocity: Int
    var averagePower: Int
    var maxPower: Int
    var averageTTP: Double
    var maxTTP: Double
    
    init(completedReps: [CompletedRep]) {
        self.completedReps = completedReps
        for completedRep in completedReps {
            averageVelocityArray.append(completedRep.averageVelocity)
            maxVelocityArray.append(Int(completedRep.maxVelocity * 100))
            averagePowerArray.append(completedRep.averagePower)
            maxPowerArray.append(completedRep.maxPower)
            ttpArray.append(completedRep.timeToPeak)
        }
        
        let averageVelocityDouble = Double(averageVelocityArray.reduce(0, +)) / Double(averageVelocityArray.count)
        averageVelocity = Int(averageVelocityDouble)
        maxVelocity = maxVelocityArray.max() ?? 0
        
        let averagePowerDouble = Double(averagePowerArray.reduce(0, +)) / Double(averagePowerArray.count)
        averagePower = Int(averagePowerDouble)
        maxPower = maxPowerArray.max() ?? 0
        
        averageTTP = ttpArray.reduce(0, +) / Double(ttpArray.count)
        maxTTP = ttpArray.min() ?? Double(0.0)
    }
}
