//
//  testSegueVC.swift
//  Joule-Power-Training
//
//  Created by Drew Shayotovich on 8/2/22.
//

import UIKit

class testSegueVC: UIViewController {

    var currentWorkout: ScheduledWorkout = ScheduledWorkout(uniqueID: "default", athleteName: "default", athleteFirst: "default", athleteLast: "default", exercise: "default", setNumber: 0, targetLoad: 0, targetReps: 0, targetVelocity: 0, weekOfYear: 0, weekYear: 0, workoutCompleted: true)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController = self.navigationController {
            let navCount = navigationController.viewControllers.count
            print("Nav Count: \(navCount)")
            if navCount > 4 {
                navigationController.viewControllers.remove(at: navCount - 2)
            }
        }
        
        print(currentWorkout.athleteName)
        print("Current Workout Found: \(currentWorkout)")
        
    }
    
}
