//
//  testSegueVC.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 8/2/22.
//

import UIKit

class testSegueVC: UIViewController {

    var currentWorkout: ScheduledWorkout = ScheduledWorkout(uniqueID: "default", athleteName: "default", athleteFirst: "default", athleteLast: "default", exercise: "default", setNumber: 0, targetLoad: 0, targetReps: 0, targetVelocity: 0, weekOfYear: 0, weekYear: 0, workoutCompleted: true)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentWorkout.athleteName)
        print("Current Workout Found: \(currentWorkout)")
        
    }
    
}
