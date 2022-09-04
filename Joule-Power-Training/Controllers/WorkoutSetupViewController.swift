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
    
    // UI Elements
    @IBOutlet weak var athleteGroupTable: UITableView!
    @IBOutlet weak var continueBarButton: UIBarButtonItem!
    @IBOutlet weak var weekOfCalendar: UIDatePicker!
    @IBOutlet weak var exercisePicker: UIPickerView!
    var availableExerciseStrings: [String] = [" - Select Exercise - ", "Squat"]
    
    // Border UIViews and Constraints
    @IBOutlet weak var groupTableBorder: UIView!
    @IBOutlet weak var weekOfBorder: UIView!
    @IBOutlet weak var exerciseBorder: UIView!
    @IBOutlet weak var weekOfPanelHeight: NSLayoutConstraint!
    @IBOutlet weak var exercisePanelHeight: NSLayoutConstraint!
    
    // Workout Session Query and Segue Variables
    var currentUserEmail: String = ""
    var currentTeamName: String = ""
    var availableGroups: [Group] = []
    var availableAthletes: [String] = []

    // Search Bar Setup
    @IBOutlet weak var groupSearchBar: UISearchBar!
    var availableGroupsSearch: [Group] = []
    var searching: Bool = false

    // Continue Button and Segue Logic
    var groupIsSelected: Bool = false
    var exerciseIsSelected: Bool = false
    var groupSelection: String = ""
    var exerciseSelection: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true

        // Delegate and Data Source Designation
        groupSearchBar.delegate = self
        self.exercisePicker.delegate = self
        self.exercisePicker.dataSource = self
        self.athleteGroupTable.delegate = self
        
        self.athleteGroupTable.dataSource = self
        athleteGroupTable.register(UINib(nibName: K.tableCells.groupTableCell, bundle: nil), forCellReuseIdentifier: K.tableCells.groupTableCell)
        self.athleteGroupTable.rowHeight = 52.0
        
        // Load Groups for GroupTable and Format VC
        loadAvailableGroupsTable()
        formatView()

        
    }
    
    func formatView() {
        addViewBorders(uiView: self.groupTableBorder)
        addViewBorders(uiView: self.exerciseBorder)
        self.weekOfPanelHeight.constant = view.frame.height / 3.0
        self.exercisePanelHeight.constant = view.frame.height / 8.0
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
                            let groupFound = Group(groupName: document["groupName"] as! String, groupCount: document["groupCount"] as! Int, groupIcon: document["groupIcon"] as! String)
                            
                            self.availableGroups.append(groupFound)
                        }
                    }
                }
                
                DispatchQueue.main.async {
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
            if self.availableAthletes.count > 0 {
                self.groupIsSelected = true
                if self.exerciseIsSelected && self.groupIsSelected {
                    self.continueBarButton.isEnabled = true
                }
            } else {
                let dialogMessage = UIAlertController(title: "No Athletes Available!", message: "This group contains no athletes. Please select another group to continue.", preferredStyle: .alert)
                 
                 let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                     if let indexPath = self.athleteGroupTable.indexPathForSelectedRow {
                         self.athleteGroupTable.deselectRow(at: indexPath, animated: true)
                     }
                 })
                
                 dialogMessage.addAction(ok)
                 self.present(dialogMessage, animated: true, completion: nil)
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
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        availableGroupsSearch = availableGroups.filter {$0.groupName.lowercased().prefix(searchText.count) == searchText.lowercased() }
        searching = true
        athleteGroupTable.reloadData()
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
        athleteGroupTable.reloadData()
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
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = availableExerciseStrings[row]
        pickerLabel?.textColor = UIColor(named: K.colors.mainFont)
        
        return pickerLabel!
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

        if searching {
            return availableGroupsSearch.count
        } else {
            return availableGroups.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Load Table Cells based on if searching or not
        if searching {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCells.groupTableCell, for: indexPath) as! GroupTableCell
            cell.groupLabel.text = availableGroupsSearch[indexPath.row].groupName
            cell.groupCountLabel.text = "Number of Athletes: \(availableGroupsSearch[indexPath.row].groupCount)"
            cell.groupIconImage.image = UIImage(named: availableGroupsSearch[indexPath.row].groupIcon)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.tableCells.groupTableCell, for: indexPath) as! GroupTableCell
            cell.groupLabel.text = availableGroups[indexPath.row].groupName
            cell.groupCountLabel.text = "Number of Athletes: \(availableGroups[indexPath.row].groupCount)"
            cell.groupIconImage.image = UIImage(named: availableGroups[indexPath.row].groupIcon)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searching {
            groupSelection = availableGroupsSearch[indexPath.row].groupName
        } else {
            groupSelection = availableGroups[indexPath.row].groupName
        }
        
        // Load players for seleted group
        getGroupedPlayers(group: groupSelection)
        
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
