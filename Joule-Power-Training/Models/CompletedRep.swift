//
//  CompletedRep.swift
//  Joule-Power-Training
//
//  Created by Drew Shayotovich on 7/7/22.
//

import Foundation

class CompletedRep {
    // Variables used to initialize class
    let timeArray: [Double]
    let velocityArray: [Double]
    let load: Int
    let targetVelocity: Int
    
    // Variables calculated
    var normalizedTimeArray: [Double] = []
    var accelerationArray: [Double] = []
    var powerArray: [Int] = []
    var accelerationTimeArray: [Double] = []
    
    let bottomSquatTime: Double
    var loadInKG: Double

    let averageVelocity: Int
    let minVelocity: Double
    let maxVelocity: Double
    let averagePower: Int
    let maxPower: Int
    let timeToPeak: Double
    
    // Velocity Curve Indexes
    let beginRepIndex: Int
    let minVelocityIndex: Int
    let breakpointIndex: Int
    let maxVelocityIndex: Int
    let endRepIndex: Int
    var zeroToMinArray: [Double] = []
    var minToMaxArray: [Double] = []
    var maxToEndArray: [Double] = []
    
    init(timeArray: [Double], velocityArray: [Double], load: Int, targetVelocity: Int) {
        self.timeArray = timeArray
        self.velocityArray = velocityArray
        self.load = load
        self.targetVelocity = targetVelocity
        accelerationArray.append(Double(0.0))
        loadInKG = Double(load) * 0.453592
        
        for time in timeArray {
            let normalizedTime: Double = time - timeArray[0]
            normalizedTimeArray.append(normalizedTime)
        }
        
        //MARK: - Index Calculations
        minVelocity = velocityArray.min() ?? 0.0
        maxVelocity = velocityArray.max() ?? 0.0
        
        minVelocityIndex = velocityArray.firstIndex(of: minVelocity) ?? 0
        maxVelocityIndex = velocityArray.firstIndex(of: maxVelocity) ?? 0
        
        for index in 0 ..< minVelocityIndex {
            zeroToMinArray.append(velocityArray[index])
        }
        beginRepIndex = zeroToMinArray.lastIndex(of: Double(0.0)) ?? 0
        
        for index in minVelocityIndex ... maxVelocityIndex {
            self.minToMaxArray.append(velocityArray[index])
        }
        breakpointIndex = (minToMaxArray.firstIndex { $0 >= 0 } ?? 0) + minVelocityIndex
        if velocityArray[breakpointIndex] == 0 {
            bottomSquatTime = normalizedTimeArray[breakpointIndex]
        } else {
            let index1 = breakpointIndex
            let index0 = breakpointIndex - 1
            
            bottomSquatTime = normalizedTimeArray[index0] + (timeArray[index1] - timeArray[index0]) * (-1 * velocityArray[index0]) / (velocityArray[index1] - velocityArray[index0])
        }
        
        for index in (maxVelocityIndex + 1) ... (velocityArray.count - 1) {
            self.maxToEndArray.append(velocityArray[index])
        }
        let endRepIndexCheck = (maxToEndArray.firstIndex(of: Double(0.0)) ?? velocityArray.count - 1) + maxVelocityIndex
        if endRepIndexCheck > (velocityArray.count - 1) {
            endRepIndex = 60
        } else {
            endRepIndex = endRepIndexCheck + 1
        }
        
        
        //MARK: - Average Velocity Calculation
        let concentricVelocity = velocityArray[breakpointIndex ... (endRepIndex - 1)]
        print("Reduce: \(Double(concentricVelocity.reduce(0, +)))")
        print("Count: \(concentricVelocity.count)")
        let averageVelocityDouble = Double(concentricVelocity.reduce(0, +)) / Double(concentricVelocity.count)
        print("Average: \(averageVelocityDouble)")
        averageVelocity = Int(averageVelocityDouble * 100)

        
        //MARK: - Acceleration and Power Calculations
        for index in (beginRepIndex + 1) ... (breakpointIndex) {
            var currentAcceleration = velocityArray[index] / (normalizedTimeArray[index] - normalizedTimeArray[beginRepIndex])
            currentAcceleration = currentAcceleration + 9.81
            
            accelerationArray.append(currentAcceleration)
            accelerationTimeArray.append(normalizedTimeArray[index])
            
            let force = loadInKG * currentAcceleration
            let power = force * velocityArray[index]
            powerArray.append(Int(power))
        }
        
        for index in (breakpointIndex + 1) ... (endRepIndex) {
            var currentAcceleration = velocityArray[index] / (normalizedTimeArray[index] - bottomSquatTime)
            currentAcceleration = currentAcceleration + 9.81
            
            accelerationArray.append(currentAcceleration)
            accelerationTimeArray.append(normalizedTimeArray[index])
            
            let force = loadInKG * currentAcceleration
            let power = force * velocityArray[index]
            powerArray.append(Int(power))
        }
        
        let concentricPower = powerArray.filter { $0 > 0 }
        averagePower = concentricPower.reduce(0,+) / concentricPower.count
        maxPower = concentricPower.max() ?? 0

        
        //MARK: - Time to Peak Calculation
        timeToPeak = normalizedTimeArray[maxVelocityIndex] - bottomSquatTime
    }
}
