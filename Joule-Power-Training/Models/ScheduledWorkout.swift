//
//  ScheduledWorkout.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 6/5/22.
//

import Foundation
import Firebase

struct ScheduledWorkout {
    let uniqueID: String
    let athleteName: String
    let athleteFirst: String
    let athleteLast: String
    let exercise: String
    let setNumber: Int
    var targetLoad: Int
    var targetReps: Int
    var targetVelocity: Int
    let week: Timestamp
    var workoutCompleted: Bool
}
