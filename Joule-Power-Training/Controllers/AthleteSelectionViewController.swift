//
//  AthleteSelectionViewController.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 6/3/22.
//

import UIKit
import Firebase

class AthleteSelectionViewController: UIViewController, UITableViewDelegate {
    
    let db = Firestore.firestore()

    var selectedAthlete: String = ""
    var availableAthletes: [String] = []
    var selectedGroup: String = ""
    var selectedExercise: String = ""
    var selectedWeek: Date = Date()
    var currentTeamName: String = ""
    let dateFormatter = DateFormatter()
    
    var scheduledWorkouts: [ScheduledWorkout] = []
    
    @IBOutlet weak var beginWorkoutButton: UIBarButtonItem!
    
    @IBOutlet weak var athleteTable: UITableView!
    @IBOutlet weak var setNumberTable: UITableView!
    
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var setWeightLabel: UILabel!
    @IBOutlet weak var setVelocityLabel: UILabel!
    @IBOutlet weak var setRepsLabel: UILabel!
    
    @IBOutlet weak var setNumberStepper: UIStepper!
    @IBOutlet weak var setWeightStepper: UIStepper!
    @IBOutlet weak var setVelocityStepper: UIStepper!
    @IBOutlet weak var setRepsStepper: UIStepper!
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        beginWorkoutButton.isEnabled = false
        
        self.athleteTable.delegate = self
        self.athleteTable.dataSource = self
        dateFormatter.dateFormat = "mm/DD/yyyy"
        
        navigationItem.hidesBackButton = true
        
        athleteTable.layer.masksToBounds = true
        athleteTable.layer.borderColor = UIColor(red: 51/255, green: 71/255, blue: 86/255, alpha: 1.0).cgColor
        athleteTable.layer.borderWidth = 2.0
        
        getGroupedPlayers(group: selectedGroup)
    }
    
    func getGroupedPlayers(group:String) {
        availableAthletes = []
        db.collection("athletes").document(currentTeamName).collection("names").whereField("groups", arrayContains: group).getDocuments { querySnapshot, err in
            if let err = err {
                print("\(err)")
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for document in snapshotDocuments {
                        self.availableAthletes.append(document.documentID)
                    }
                }
            }
            print(self.availableAthletes)
            DispatchQueue.main.async {
                print("updatingAthleteTable")
                self.athleteTable.reloadData()
            }
        }
    }
    
    func getAvailableSets(athleteName: String) {
        scheduledWorkouts = []
        
        db.collection("athletes").document(currentTeamName).collection("scheduledWorkouts")
            .whereField("athleteName", isEqualTo: athleteName)
            .whereField("exercise", isEqualTo: selectedExercise)
            .whereField("week", isEqualTo: selectedWeek)
            .whereField("workoutCompleted", isEqualTo: false)
            .order(by: "setNumber")
            .getDocuments { querySnapshot, err in
                if let err = err {
                    print("\(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let dataFound = document.data()
                        let uniqueIDFound = document.documentID
                        let athleteNameFound: String = dataFound["athleteName"] as! String
                        let athleteFirstFound: String = dataFound["athleteFirst"] as! String
                        let athleteLastFound: String = dataFound["athleteLast"] as! String
                        let exerciseFound: String = dataFound["exercise"] as! String
                        let setNumberFound: Int = dataFound["setNumber"] as! Int
                        let targetLoadFound: Int = dataFound["targetLoad"] as! Int
                        let targetRepsFound: Int = dataFound["targetReps"] as! Int
                        let targetVelocityFound: Int = dataFound["targetVelocity"] as! Int
                        let weekFound: Timestamp = dataFound["week"] as! Timestamp
                        let completedWorkoutFound: Bool = false
                        
                        let discoveredScheduledWorkout = ScheduledWorkout(uniqueID: uniqueIDFound, athleteName: athleteNameFound, athleteFirst: athleteFirstFound, athleteLast: athleteLastFound, exercise: exerciseFound, setNumber: setNumberFound, targetLoad: targetLoadFound, targetReps: targetRepsFound, targetVelocity: targetVelocityFound, week: weekFound, workoutCompleted: completedWorkoutFound)

                        self.scheduledWorkouts.append(discoveredScheduledWorkout)
                    }
                }
                if let firstScheduledWorkout = self.scheduledWorkouts.first, let lastScheduledWorkout = self.scheduledWorkouts.last  {
                    // Set Number Settings
                    self.setNumberStepper.minimumValue = Double(firstScheduledWorkout.setNumber)
                    self.setNumberStepper.maximumValue = Double(lastScheduledWorkout.setNumber)
                    self.setNumberStepper.value = Double(firstScheduledWorkout.setNumber)
                    self.setNumberStepper.isEnabled = true
                    self.setNumberLabel.text = String(firstScheduledWorkout.setNumber)
                    
                    // Set Weight Settings
                    self.setWeightStepper.value = Double(firstScheduledWorkout.targetLoad)
                    self.setWeightLabel.text = String(firstScheduledWorkout.targetLoad)
                    self.setWeightStepper.isEnabled = true
                    
                    // Set Velocity Settings
                    let doubleVelocityValue = Double(firstScheduledWorkout.targetVelocity) / 100.0
                    self.setVelocityStepper.value = doubleVelocityValue
                    self.setVelocityLabel.text = String(format: "%.2f", doubleVelocityValue)
                    self.setVelocityStepper.isEnabled = true
                    
                    // Set Reps Settings
                    self.setRepsStepper.value = Double(firstScheduledWorkout.targetReps)
                    self.setRepsLabel.text = String(firstScheduledWorkout.targetReps)
                    self.setRepsStepper.isEnabled = true
                
                } else {
                    // ERROR NO WORKOUTS FOUND ALERT
                }
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let finalWorkoutIndex = Int(setNumberStepper.value) - Int(setNumberStepper.minimumValue)
        
        let selectedWorkout = scheduledWorkouts[finalWorkoutIndex]
        let newTargetLoad = Int(setWeightStepper.value)
        let newTargetVelocity = Int(setVelocityStepper.value * 100)
        let newTargetReps = Int(setRepsStepper.value)
        
        let finalWorkout = ScheduledWorkout(uniqueID: selectedWorkout.uniqueID, athleteName: selectedWorkout.athleteName, athleteFirst: selectedWorkout.athleteFirst, athleteLast: selectedWorkout.athleteLast, exercise: selectedWorkout.exercise, setNumber: selectedWorkout.setNumber, targetLoad: newTargetLoad, targetReps: newTargetReps, targetVelocity: newTargetVelocity, week: selectedWorkout.week, workoutCompleted: false)
        
        let destinationVC = segue.destination as! WorkoutCameraViewController
        destinationVC.currentWorkout = finalWorkout
        
        db.collection("athletes").document(currentTeamName).collection("scheduledWorkouts").document(finalWorkout.uniqueID).updateData([
            "targetLoad": finalWorkout.targetLoad,
            "targetReps": finalWorkout.targetReps,
            "targetVelocity": finalWorkout.targetVelocity
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    @IBAction func beginWorkoutPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: K.segues.athleteSelectionToWorkoutTracker, sender: self)
    }
    
    @IBAction func setNumberChanged(_ sender: Any) {
        let scheduledWorkoutsIndex: Int = Int(setNumberStepper.value) - Int(setNumberStepper.minimumValue)
        
        setNumberLabel.text = String(scheduledWorkouts[scheduledWorkoutsIndex].setNumber)
        setWeightLabel.text = String(scheduledWorkouts[scheduledWorkoutsIndex].targetLoad)
        let  changedDoubleVelocity = Double(scheduledWorkouts[scheduledWorkoutsIndex].targetVelocity) / 100.0
        setVelocityLabel.text = String(format: "%.2f", changedDoubleVelocity)
        setRepsLabel.text = String(scheduledWorkouts[scheduledWorkoutsIndex].targetReps)
        
        setWeightStepper.value = Double(scheduledWorkouts[scheduledWorkoutsIndex].targetLoad)
        setVelocityStepper.value = changedDoubleVelocity
        setRepsStepper.value = Double(scheduledWorkouts[scheduledWorkoutsIndex].targetReps)
    }
    
    @IBAction func setWeightChanged(_ sender: Any) {
        setWeightLabel.text = String(Int(setWeightStepper.value))
    }
    
    @IBAction func setVelocityChanged(_ sender: Any) {
        setVelocityLabel.text = String(format: "%.2f", setVelocityStepper.value)
    }
    
    @IBAction func setRepsChanged(_ sender: Any) {
        setRepsLabel.text = String(Int(setRepsStepper.value))
    }
}

extension AthleteSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == athleteTable {
            print(availableAthletes.count)
            return availableAthletes.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == athleteTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "athleteTableCell", for: indexPath)
            cell.textLabel?.text = availableAthletes[indexPath.row]
//            var content = cell.defaultContentConfiguration()
//            content.text = availableAthletes[indexPath.row]
//            content.textProperties.color = UIColor.black
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "athleteTableCell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "No Athletes Found"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == athleteTable {
            selectedAthlete = availableAthletes[indexPath.row]
            getAvailableSets(athleteName: selectedAthlete)
            beginWorkoutButton.isEnabled = true
        }
    }
}


