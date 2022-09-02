//
//  PartialCompletedRep.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 7/31/22.
//

import Foundation

class PartialCompetedRep {
    // Variables used to initialize class
    let timeArray: [Double]
    let velocityArray: [Double]
    var minToMaxArray: [Double] = []
    var maxToEndArray: [Double] = []
    let endRepIndex: Int
    let averageVelocity: Int
    let feedbackColor: String
   
    init(timeArray: [Double], velocityArray: [Double], targetVelocity: Int) {
        self.velocityArray = velocityArray
        self.timeArray = timeArray
        
        let minVelocity = velocityArray.min() ?? 0.0
        let maxVelocity = velocityArray.max() ?? 0.0
        
        let minVelocityIndex = velocityArray.firstIndex(of: minVelocity) ?? 0
        let maxVelocityIndex = velocityArray.firstIndex(of: maxVelocity) ?? 0
        
        for index in minVelocityIndex ... maxVelocityIndex {
            self.minToMaxArray.append(velocityArray[index])
        }
        let breakpointIndex = (minToMaxArray.firstIndex { $0 >= 0 } ?? 0) + minVelocityIndex
        
        for index in (maxVelocityIndex + 1) ... (velocityArray.count - 1) {
            self.maxToEndArray.append(velocityArray[index])
        }
        let endRepIndexCheck = (maxToEndArray.firstIndex(of: Double(0.0)) ?? velocityArray.count - 1) + maxVelocityIndex
        if endRepIndexCheck > (velocityArray.count - 1) {
            endRepIndex = 60
        } else {
            endRepIndex = endRepIndexCheck + 1
        }
        
        let concentricVelocity = velocityArray[breakpointIndex ... (endRepIndex - 1)]
        
        let averageVelocityDouble = Double(concentricVelocity.reduce(0, +)) / Double(concentricVelocity.count)
        
        averageVelocity = Int(averageVelocityDouble * 100)
        
        if averageVelocity >= targetVelocity {
            feedbackColor = K.colors.feedbackGreen
        } else if averageVelocity >= targetVelocity - 5 {
            feedbackColor = K.colors.feedbackYellow
        } else {
            feedbackColor = K.colors.feedbackRed
        }
    }
}
