//
//  WorkoutSelectionViewController.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 4/7/22.
//

import UIKit
import Firebase

class WorkoutSetupViewController: UIViewController, UITableViewDelegate, UIPickerViewDelegate {
        
    let db = Firestore.firestore()
    
    @IBOutlet weak var runSensorButton: UIButton!
    @IBOutlet weak var bleAvailableDeviceTable: UITableView!
    @IBOutlet weak var exerciseSelectionTable: UITableView!
    @IBOutlet weak var athleteGroupTable: UITableView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var weekOfCalendar: UIDatePicker!
    
    var currentUserEmail: String = ""
    var currentTeamName: String = ""
    var availableExercises: [String] = ["Squat", "Front Squat", "Bench", "Incline", "Power Clean"]
    var availableGroups: [String] = []
    var availableAthletes: [String] = []
    
    var groupIsSelected: Bool = false
    var exerciseIsSelected: Bool = false
    
    var groupSelection: String = ""
    var exerciseSelection: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.exerciseSelectionTable.delegate = self
        self.exerciseSelectionTable.dataSource = self
        
        self.athleteGroupTable.delegate = self
        self.athleteGroupTable.dataSource = self
        
        navigationItem.hidesBackButton = true
        
        loadAvailableGroupsTable()
        
        athleteGroupTable.layer.masksToBounds = true
        athleteGroupTable.layer.borderColor = UIColor(red: 51/255, green: 71/255, blue: 86/255, alpha: 1.0).cgColor
        athleteGroupTable.layer.borderWidth = 2.0
        
        exerciseSelectionTable.layer.masksToBounds = true
        exerciseSelectionTable.layer.borderColor = UIColor(red: 51/255, green: 71/255, blue: 86/255, alpha: 1.0).cgColor
        exerciseSelectionTable.layer.borderWidth = 2.0
        
        continueButton.alpha = 0.25
                
    }
    
    func loadAvailableGroupsTable() {
        availableGroups = []
        db.collection("authorizedUsers").whereField("emails", arrayContains: currentUserEmail).getDocuments { querySnapshot, err in
            if let err = err {
                print("\(err)")
            } else {
                self.currentTeamName = querySnapshot!.documents[0].documentID
            }
            
            self.db.collection("teamInformation").document(self.currentTeamName).getDocument { document, err in
                if let err = err {
                    print("\(err)")
                } else {
                    if let document = document {
                        self.availableGroups = document["groups"]! as! [String]
                    }
                }
                DispatchQueue.main.async {
                    print("updatingTable")
                    self.athleteGroupTable.reloadData()
                }
            }
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.segues.setupToAthleteSelection {
            if let destinationVC: AthleteSelectionViewController = segue.destination as? AthleteSelectionViewController {
                
                let uiDate = weekOfCalendar.date
                let weekOfYear = Int(weekOfCalendar.calendar.component(.weekOfYear, from: uiDate))
                let weekYear = Int(weekOfCalendar.calendar.component(.year, from: uiDate))
                
                destinationVC.selectedWeekOfYear = weekOfYear
                destinationVC.selectedWeekYear = weekYear
                destinationVC.selectedWeek = uiDate.mondayOfTheSameWeek
                destinationVC.selectedExercise = exerciseSelection
                destinationVC.selectedGroup = groupSelection
                destinationVC.currentTeamName = currentTeamName
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
    
    @IBAction func continuePressed(_ sender: Any) {
        performSegue(withIdentifier: K.segues.setupToAthleteSelection, sender: self)
    }
}

extension WorkoutSetupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == exerciseSelectionTable {
            return availableExercises.count
        } else if tableView == athleteGroupTable {
            return availableGroups.count
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if tableView == exerciseSelectionTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCells.exerciseTableCell, for: indexPath)
            cell.textLabel?.text = availableExercises[indexPath.row]
            return cell
        } else if tableView == athleteGroupTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCells.groupTableCell, for: indexPath)
            cell.textLabel?.text = availableGroups[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCells.groupTableCell, for: indexPath)
            cell.textLabel?.text = "cellForRowAt ELSE Statement"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == exerciseSelectionTable {
            exerciseIsSelected = true
            exerciseSelection = availableExercises[indexPath.row]
        } else if tableView == athleteGroupTable {
            groupIsSelected = true
            groupSelection = availableGroups[indexPath.row]
        }
        
        if exerciseIsSelected && groupIsSelected {
            continueButton.isEnabled = true
            continueButton.alpha = 1.0
        }
        
    }
}

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
    static let iso8601UTC: Calendar = {
            var calendar = Calendar(identifier: .iso8601)
            calendar.timeZone = TimeZone(identifier: "UTC")!
            return calendar
        }()
}

extension Date {
    var mondayOfTheSameWeek: Date {
        Calendar.iso8601.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}
