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
    
    @IBOutlet weak var athleteGroupTable: UITableView!
    @IBOutlet weak var continueBarButton: UIBarButtonItem!
    @IBOutlet weak var weekOfCalendar: UIDatePicker!
    @IBOutlet weak var exercisePicker: UIPickerView!
    @IBOutlet weak var groupSearchBar: UISearchBar!
    
    var currentUserEmail: String = ""
    var currentTeamName: String = ""
    var availableExerciseStrings: [String] = [" - Select Exercise - ", "Squat", "Front Squat", "Bench", "Incline Bench", "Power Clean", "Hang Clean"]
    var availableGroups: [Group] = []
    var availableAthletes: [String] = []
    
    var groupIsSelected: Bool = false
    var exerciseIsSelected: Bool = false
    
    var groupSelection: String = ""
    var exerciseSelection: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupSearchBar.delegate = self
        
        self.athleteGroupTable.delegate = self
        self.athleteGroupTable.dataSource = self
        athleteGroupTable.register(UINib(nibName: "GroupTableCell", bundle: nil), forCellReuseIdentifier: "GroupTableCell")
        self.athleteGroupTable.rowHeight = 72.0
        
        navigationItem.hidesBackButton = true
        
        loadAvailableGroupsTable()
        
        self.exercisePicker.delegate = self
        self.exercisePicker.dataSource = self
        
        athleteGroupTable.layer.masksToBounds = true
        athleteGroupTable.layer.borderColor = UIColor(red: 51/255, green: 71/255, blue: 86/255, alpha: 1.0).cgColor
        athleteGroupTable.layer.borderWidth = 1.0
    }

    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    @IBAction func continueBarButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: K.segues.setupToAthleteSelection, sender: self)
    }
    
}

//MARK: - Firestore Database Functions
extension WorkoutSetupViewController {
    func loadAvailableGroupsTable() {
        availableGroups = []
        db.collection("authorizedUsers").whereField("emails", arrayContains: currentUserEmail).getDocuments { querySnapshot, err in
            if let err = err {
                print("\(err)")
            } else {
                self.currentTeamName = querySnapshot!.documents[0].documentID
            }
            
            self.db.collection("teamInformation").document(self.currentTeamName).collection("groups").order(by: "groupName").getDocuments { querySnapshot, err in
                
                if let err = err {
                    print("\(err)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for document in snapshotDocuments {
                            let groupFound = Group(groupName: document["groupName"] as! String, groupCount: document["groupCount"] as! Int)
                            
                            self.availableGroups.append(groupFound)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    print("updatingAthleteTable")
                    self.athleteGroupTable.reloadData()
                }
            }
        }
    }
    
    func getGroupedPlayers(group:String) {
        availableAthletes = []
        groupIsSelected = false
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
            self.groupIsSelected = true
            if self.exerciseIsSelected && self.groupIsSelected {
                self.continueBarButton.isEnabled = true
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
                destinationVC.availableAthletes = availableAthletes
            }
        }
    }
}

//MARK: - Search Bar Delegate
extension WorkoutSetupViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

//MARK: - Picker Data Source
extension WorkoutSetupViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableExerciseStrings.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return availableExerciseStrings[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row != Int(0) {
            exerciseIsSelected = true
            exerciseSelection = availableExerciseStrings[row]
        } else {
            exerciseIsSelected = false
        }
        
        if exerciseIsSelected && groupIsSelected {
            continueBarButton.isEnabled = true
        }
    }
}

//MARK: - TableView Data Source
extension WorkoutSetupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView == athleteGroupTable {
            return availableGroups.count
        } else {
            return 100
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == athleteGroupTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupTableCell", for: indexPath) as! GroupTableCell
            cell.groupLabel.text = availableGroups[indexPath.row].groupName
            cell.groupCountLabel.text = "Number of Athletes: \(availableGroups[indexPath.row].groupCount)"
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCells.groupTableCell, for: indexPath)
            cell.textLabel?.text = "cellForRowAt ELSE Statement"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == athleteGroupTable {
            groupSelection = availableGroups[indexPath.row].groupName
            getGroupedPlayers(group: groupSelection)
        }
        
        if exerciseIsSelected && groupIsSelected {
            continueBarButton.isEnabled = true
        }
    }
}

//MARK: - Calendar and Date
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
