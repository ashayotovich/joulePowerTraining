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

    // Variables for Segue + Set Data
    var selectedAthlete: String = ""
    var availableAthletes: [String] = []
    var selectedGroup: String = ""
    var selectedExercise: String = ""
    var selectedWeekOfYear: Int = 0
    var selectedWeekYear: Int = 0
    var currentTeamName: String = ""
    let dateFormatter = DateFormatter()
    
    // 
    var scheduledWorkouts: [ScheduledWorkout] = []
    var allSessionWorkouts: [ScheduledWorkout] = []
    var sessionAthletes: [AthleteTableEntry] = []
    
    @IBOutlet weak var beginWorkoutButton: UIBarButtonItem!
    
    @IBOutlet weak var athleteTable: UITableView!
    
    
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var setWeightLabel: UILabel!
    @IBOutlet weak var setVelocityLabel: UILabel!
    @IBOutlet weak var setRepsLabel: UILabel!
    
    @IBOutlet weak var setNumberStepper: UIStepper!
    @IBOutlet weak var setWeightStepper: UIStepper!
    @IBOutlet weak var setVelocityStepper: UIStepper!
    @IBOutlet weak var setRepsStepper: UIStepper!
    
    // Border UIViews
    @IBOutlet weak var athleteTableBorder: UIView!
    @IBOutlet weak var setNumberBorder: UIView!
    @IBOutlet weak var setLoadBorder: UIView!
    @IBOutlet weak var setVelocityBorder: UIView!
    @IBOutlet weak var setRepsBorder: UIView!
    
    // Constraints for Adjusting Layout
    @IBOutlet weak var athleteTableHeight: NSLayoutConstraint!
    @IBOutlet weak var topViewSpacer: NSLayoutConstraint!
    @IBOutlet weak var leftViewSpacer: NSLayoutConstraint!
    @IBOutlet weak var middleViewSpacer: NSLayoutConstraint!
    @IBOutlet weak var bottomViewSpacer: NSLayoutConstraint!
    @IBOutlet weak var rightViewSpacer: NSLayoutConstraint!

    // Search Bar Setup
    @IBOutlet weak var athleteSearchBar: UISearchBar!
    var sessionAthletesSearch: [AthleteTableEntry] = []
    var searching: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        clearPreviousSelections()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if setNumberLabel.text != "" {
            clearPreviousSelections()
        }
        
        athleteTableHeight.constant = view.frame.height / 2
        addViewBorders(uiView: athleteTableBorder)
        addViewBorders(uiView: setNumberBorder)
        addViewBorders(uiView: setLoadBorder)
        addViewBorders(uiView: setVelocityBorder)
        addViewBorders(uiView: setRepsBorder)
        
        topViewSpacer.constant = view.frame.width / 30
        leftViewSpacer.constant = view.frame.width / 30
        middleViewSpacer.constant = view.frame.width / 30
        bottomViewSpacer.constant = view.frame.width / 30
        rightViewSpacer.constant = view.frame.width / 30

        athleteSearchBar.delegate = self
        
        beginWorkoutButton.isEnabled = false
        
        self.athleteTable.delegate = self
        self.athleteTable.dataSource = self
        athleteTable.register(UINib(nibName: "AthleteTableCell", bundle: nil), forCellReuseIdentifier: "AthleteTableCell")
        self.athleteTable.rowHeight = 52.0
        
        dateFormatter.dateFormat = "mm/DD/yyyy"
        
        navigationItem.hidesBackButton = true
        
        loadAllSessionWorkouts()
    }
    
    func clearPreviousSelections() {
        beginWorkoutButton.isEnabled = false
        setNumberLabel.text = ""
        setRepsLabel.text = ""
        setWeightLabel.text = ""
        setVelocityLabel.text = ""
        
        setNumberStepper.isEnabled = false
        setRepsStepper.isEnabled = false
        setWeightStepper.isEnabled = false
        setVelocityStepper.isEnabled = false
        
        if let indexPath = athleteTable.indexPathForSelectedRow {
            athleteTable.deselectRow(at: indexPath, animated: true)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            do {
                try Auth.auth().signOut()
                navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
                print("Error signing out: \(signOutError)")
            }
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
        
        colorTransition(label: self.setNumberLabel, colorNamed1: "Color5", colorNamed2: "Color1-2")
        colorTransition(label: self.setWeightLabel, colorNamed1: "Color5", colorNamed2: "Color1-2")
        colorTransition(label: self.setVelocityLabel, colorNamed1: "Color5", colorNamed2: "Color1-2")
        colorTransition(label: self.setRepsLabel, colorNamed1: "Color5", colorNamed2: "Color1-2")
    }
    
    @IBAction func setWeightChanged(_ sender: Any) {
        setWeightLabel.text = String(Int(setWeightStepper.value))
        colorTransition(label: self.setWeightLabel, colorNamed1: "Color5", colorNamed2: "Color1-2")
    }
    
    @IBAction func setVelocityChanged(_ sender: Any) {
        setVelocityLabel.text = String(format: "%.2f", setVelocityStepper.value)
        colorTransition(label: self.setVelocityLabel, colorNamed1: "Color5", colorNamed2: "Color1-2")
    }
    
    @IBAction func setRepsChanged(_ sender: Any) {
        setRepsLabel.text = String(Int(setRepsStepper.value))
        colorTransition(label: self.setRepsLabel, colorNamed1: "Color5", colorNamed2: "Color1-2")
    }
}

//MARK: - View Controller Helper Funcitons
extension UIViewController {
    func colorTransition(label: UILabel, colorNamed1:String, colorNamed2:String) {
        UIView.transition(with: label, duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: {
            label.textColor = UIColor(named: colorNamed1)
        }, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25) {
            UIView.transition(with: label, duration: 0.25,
                              options: .transitionCrossDissolve,
                              animations: {
                label.textColor = UIColor(named: colorNamed2)
            }, completion: nil)
        }
    }
    
    func addViewBorders(uiView: UIView) {
        uiView.layer.masksToBounds = false
        uiView.layer.shadowOpacity = 1.0
        uiView.layer.shadowRadius = 2.5
        uiView.layer.shadowOffset = CGSize.zero
        uiView.layer.shadowColor = UIColor.black.cgColor
    }
}

extension AthleteSelectionViewController {
    func loadAllSessionWorkouts() {
        allSessionWorkouts = []
        sessionAthletes = []
        
        db.collection("athletes").document(currentTeamName).collection("scheduledWorkouts")
            .whereField("athleteName", in: availableAthletes)
            .whereField("exercise", isEqualTo: selectedExercise)
            .whereField("weekOfYear", isEqualTo: selectedWeekOfYear)
            .whereField("weekYear", isEqualTo: selectedWeekYear)
            .whereField("workoutCompleted", isEqualTo: false)
            .order(by: "setNumber")
            .getDocuments { querySnapshot, err in
                if let err = err {
                    print("\(err)")
                } else {
                    let queryDocuments = querySnapshot!.documents
                    
                    for athleteName in self.availableAthletes {
                        var athleteExerciseCount = 0
                        for document in queryDocuments {
                            let dataFound = document.data()
                            if dataFound["athleteName"] as! String == athleteName {
                                athleteExerciseCount += 1
                            }
                        }
                        let newAthleteTableEntry = AthleteTableEntry(athleteName: athleteName, athleteAvailableExercises: athleteExerciseCount)
                        self.sessionAthletes.append(newAthleteTableEntry)
                    }
                    
                    for document in queryDocuments {
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
                        let weekOfYearFound: Int = dataFound["weekOfYear"] as! Int
                        let weekYearFound: Int = dataFound["weekYear"] as! Int
                        let completedWorkoutFound: Bool = false

                        let discoveredScheduledWorkout = ScheduledWorkout(uniqueID: uniqueIDFound, athleteName: athleteNameFound, athleteFirst: athleteFirstFound, athleteLast: athleteLastFound, exercise: exerciseFound, setNumber: setNumberFound, targetLoad: targetLoadFound, targetReps: targetRepsFound, targetVelocity: targetVelocityFound, weekOfYear: weekOfYearFound, weekYear: weekYearFound, workoutCompleted: completedWorkoutFound)

                        self.allSessionWorkouts.append(discoveredScheduledWorkout)
                    }
                    self.athleteTable.reloadData()
                }
            }
    }
    
    func getAvailableSets(athleteName: String) {
        scheduledWorkouts = allSessionWorkouts.filter { $0.athleteName == athleteName }
        
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
            print("No Workout for this athlete")
            
            let dialogMessage = UIAlertController(title: "No Workout Available!", message: "No workouts for the selected athlete in this session. Please choose another athlete to workout.", preferredStyle: .alert)
             
             let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                 self.setNumberLabel.text = ""
                 self.setWeightLabel.text = ""
                 self.setVelocityLabel.text = ""
                 self.setRepsLabel.text = ""
                 self.beginWorkoutButton.isEnabled = false
              })
             dialogMessage.addAction(ok)
             self.present(dialogMessage, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let finalWorkoutIndex = Int(setNumberStepper.value) - Int(setNumberStepper.minimumValue)
        
        let selectedWorkout = scheduledWorkouts[finalWorkoutIndex]
        let newTargetLoad = Int(setWeightStepper.value)
        let newTargetVelocity = Int(setVelocityStepper.value * 100)
        let newTargetReps = Int(setRepsStepper.value)
        
        let finalWorkout = ScheduledWorkout(uniqueID: selectedWorkout.uniqueID, athleteName: selectedWorkout.athleteName, athleteFirst: selectedWorkout.athleteFirst, athleteLast: selectedWorkout.athleteLast, exercise: selectedWorkout.exercise, setNumber: selectedWorkout.setNumber, targetLoad: newTargetLoad, targetReps: newTargetReps, targetVelocity: newTargetVelocity, weekOfYear: selectedWorkout.weekOfYear, weekYear: selectedWorkout.weekYear, workoutCompleted: false)
        
        let destinationVC = segue.destination as! WorkoutCameraViewController
        destinationVC.currentWorkout = finalWorkout
        
        db.collection("athletes").document(currentTeamName).collection("scheduledWorkouts").document(finalWorkout.uniqueID).updateData([
            "targetLoad": finalWorkout.targetLoad,
            "targetReps": finalWorkout.targetReps,
            "targetVelocity": finalWorkout.targetVelocity
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
}

//MARK: - Search Bar Delegate
extension AthleteSelectionViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sessionAthletesSearch = sessionAthletes.filter {$0.athleteName.lowercased().prefix(searchText.count) == searchText.lowercased() }
        searching = true
        athleteTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.resignFirstResponder()
        searchBar.text = ""
        athleteTable.reloadData()
    }
}

//MARK: - TableView Data Source
extension AthleteSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searching {
            print(sessionAthletesSearch.count)
            return sessionAthletesSearch.count
        } else {
            return sessionAthletes.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searching {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteTableCell", for: indexPath) as! AthleteTableCell
            cell.athleteNameLabel.text = sessionAthletesSearch[indexPath.row].athleteName
            cell.availableSetsLabel.text = "Available Sets: \(sessionAthletesSearch[indexPath.row].athleteAvailableExercises)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AthleteTableCell", for: indexPath) as! AthleteTableCell
            cell.athleteNameLabel.text = sessionAthletes[indexPath.row].athleteName
            cell.availableSetsLabel.text = "Available Sets: \(sessionAthletes[indexPath.row].athleteAvailableExercises)"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searching {
            selectedAthlete = sessionAthletesSearch[indexPath.row].athleteName
        } else {
            selectedAthlete = sessionAthletes[indexPath.row].athleteName
        }
        
        getAvailableSets(athleteName: selectedAthlete)
        beginWorkoutButton.isEnabled = true
        
    }
}


