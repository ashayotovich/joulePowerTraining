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
    
    let uniqueID: String
    let athleteName: String
    let athleteFirst: String
    let athleteLast: String
    let exercise: String
    let setNumber: Int
    let targetLoad: Int
    let targetReps: Int
    let targetVelocity: Int
    let weekOfYear: Int
    let weekYear: Int
    
    init(completedReps: [CompletedRep], currentWorkout: ScheduledWorkout) {
        self.completedReps = completedReps
        for completedRep in completedReps {
            averageVelocityArray.append(completedRep.averageVelocity)
            maxVelocityArray.append(completedRep.maxVelocity)
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
        
        uniqueID = currentWorkout.uniqueID
        athleteName = currentWorkout.athleteName
        athleteFirst = currentWorkout.athleteFirst
        athleteLast = currentWorkout.athleteLast
        exercise = currentWorkout.exercise
        setNumber = currentWorkout.setNumber
        targetLoad = currentWorkout.targetLoad
        targetReps = currentWorkout.targetReps
        targetVelocity = currentWorkout.targetVelocity
        weekOfYear = currentWorkout.weekOfYear
        weekYear = currentWorkout.weekYear
    }
}
