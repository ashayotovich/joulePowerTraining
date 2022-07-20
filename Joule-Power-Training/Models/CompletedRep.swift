//
//  CompletedRep.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/7/22.
//

import Foundation

class CompletedRep {
    // Variables used to initialize class
    let timeArray: [Double]
    let velocityArray: [Double]
    let load: Int
    let targetVelocity: Int
    
    // Variables calculated
    var accelerationArray: [Double] = []
    var powerArray: [Int] = []
    var positiveVelocities: [Double] = []
    let averageVelocity: Double
    let maxVelocity: Double
    let averagePower: Int
    let maxPower: Int
    let timeToPeak: Double
    let maxVelocityIndex: Int
    let minVelocityIndex: Int
    let averageFeedbackImageIndex: Int
    let maxFeedbackImageIndex: Int
    
    init(timeArray: [Double], velocityArray: [Double], load: Int, targetVelocity: Int) {
        self.timeArray = timeArray
        self.velocityArray = velocityArray
        self.load = load
        self.targetVelocity = targetVelocity
        accelerationArray.append(Double(0.0))
        
        for measurementIndex in 1 ..< velocityArray.count {
            let deltaVelocity = velocityArray[measurementIndex] - velocityArray[measurementIndex - 1]
            let deltaTime = timeArray[measurementIndex] - timeArray[measurementIndex - 1]
            let currentAcceleration = deltaVelocity / deltaTime
            
            accelerationArray.append(currentAcceleration)
            
            var currentPower: Int = 0
            
            if currentAcceleration < 0 {
                currentPower = 0
            } else {
                let newtonConversionFactor = 4.44822
                let kgConversionFactor = 0.453592
                let massAcceleration = Double(load) * kgConversionFactor * currentAcceleration
                let forceGravity = Double(load) * newtonConversionFactor
                
                let forceAthlete = massAcceleration + forceGravity
                currentPower = Int(forceAthlete) * Int(velocityArray[measurementIndex])
            }
            powerArray.append(currentPower)
            
            if velocityArray[measurementIndex] > 0.0 {
                positiveVelocities.append(velocityArray[measurementIndex])
            }
        }
        //MARK: - Average and Peak Calculations

        let averageVelocitySum = positiveVelocities.reduce(0, +)
        let averageVelocitySize = positiveVelocities.count
        let averageVelocity = averageVelocitySum / Double(averageVelocitySize)
        let maxVelocity = positiveVelocities.max() ?? Double(0.0)
        let minVelocity = velocityArray.min() ?? Double(0.0)
        
        let averagePowerSum = powerArray.reduce(0, +)
        let averagePowerSize = powerArray.count
        let averagePower = averagePowerSum / averagePowerSize
        let maxPower = powerArray.max() ?? Int(0)
        
        self.averageVelocity = averageVelocity
        self.maxVelocity = maxVelocity
        self.averagePower = averagePower
        self.maxPower = maxPower
        
        if averageVelocity >= (Double(targetVelocity / 100) * 1.05) {
            self.averageFeedbackImageIndex = 0
        } else if averageVelocity >= Double(targetVelocity / 100) {
            self.averageFeedbackImageIndex = 1
        } else if averageVelocity >= (Double(targetVelocity / 100) * 0.95) {
            self.averageFeedbackImageIndex = 2
        } else {
            self.averageFeedbackImageIndex = 3
        }
        
        if maxVelocity >= (Double(targetVelocity / 100) * 1.05) {
            self.maxFeedbackImageIndex = 0
        } else if maxVelocity >= Double(targetVelocity / 100) {
            self.maxFeedbackImageIndex = 1
        } else if maxVelocity >= (Double(targetVelocity / 100) * 0.95) {
            self.maxFeedbackImageIndex = 2
        } else {
            self.maxFeedbackImageIndex = 3
        }
        
        //MARK: - Time-to-Peak Calculations
        self.maxVelocityIndex = velocityArray.firstIndex(of: maxVelocity) ?? 0
        self.minVelocityIndex = velocityArray.firstIndex(of: minVelocity) ?? 0
        
        print(self.maxVelocityIndex)
        print(self.minVelocityIndex)
        
        let peakVelocityTime = timeArray[maxVelocityIndex]
        var calculatedTTP: Double = 0.0
        
        if maxVelocityIndex == 0 || minVelocityIndex == 0 {
            calculatedTTP = Double(0.0)
        } else if (maxVelocityIndex - minVelocityIndex) <= 1 {
            calculatedTTP = Double(0.0)
        } else {
            for velocityIndex in minVelocityIndex ..< maxVelocityIndex {
                if velocityArray[velocityIndex - 1] <= 0 && velocityArray[velocityIndex] > 0 {
                    let startVelocityTime = timeArray[velocityIndex - 1]
                    calculatedTTP = peakVelocityTime - startVelocityTime
                }
            }
        }
        
        self.timeToPeak = calculatedTTP
    }
}
