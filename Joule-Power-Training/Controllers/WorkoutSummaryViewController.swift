//
//  WorkoutSummaryViewController.swift
//  Joule-Power-Training
//
//  Created by Drew Shayotovich on 4/24/22.
//

import UIKit
import Firebase
import SwiftUI
import Charts

class WorkoutSummaryViewController: UIViewController, UIScrollViewDelegate {
     
    let db = Firestore.firestore()

    // Variables from Previous Segue
    var currentWorkout: ScheduledWorkout = ScheduledWorkout(uniqueID: "default", athleteName: "default", athleteFirst: "default", athleteLast: "default", exercise: "default", setNumber: 0, targetLoad: 0, targetReps: 0, targetVelocity: 0, weekOfYear: 0, weekYear: 0, workoutCompleted: true)
    
    var currentTeamName: String = ""
    
    var partialCompletedReps: [PartialCompetedRep] = []
    var completedReps: [CompletedRep] = []
    var completedSet: CompletedSet?

    var slides: [RepSummarySlide] = []
    
    @IBOutlet weak var athleteAndWorkoutInfoView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var headshotImage: UIImageView!
    @IBOutlet weak var headshotHeight: NSLayoutConstraint!
    @IBOutlet weak var headshotWidth: NSLayoutConstraint!
    
    //MARK: - Set Summary Variable Outlets
    @IBOutlet weak var setExerciseLabel: UILabel!
    @IBOutlet weak var setLoadLabel: UILabel!
    @IBOutlet weak var setVelocityTargetLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var setRepsCompletedLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    
    
    //MARK: - Set Feedback Variable Outlets
    @IBOutlet weak var averageVelocityLabel: UILabel!
    @IBOutlet weak var maxVelocityLabel: UILabel!
    @IBOutlet weak var averagePowerLabel: UILabel!
    @IBOutlet weak var maxPowerLabel: UILabel!
    @IBOutlet weak var averageTTPLabel: UILabel!
    @IBOutlet weak var maxTTPLabel: UILabel!
    @IBOutlet weak var greenTargetLabel: UILabel!
    @IBOutlet weak var yellowTargetLabel: UILabel!
    @IBOutlet weak var redTargetLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        
        dismissTrackerVC()
        analyzePartialReps(partialReps: partialCompletedReps)
                
        let saveWorkoutItem = UIAction(title: "Save Workout", image: UIImage(systemName: K.flatIcons.saveWorkout)) { (action) in
            self.saveMeasuredWorkout()
            self.updateScheduledWorkout()
            self.popToAthleteSelection()
        }
        
        let deleteWorkoutItem = UIAction(title: "Delete Workout", image: UIImage(systemName: K.flatIcons.deleteWorkout)) { (action) in
            self.deleteMeasuredWorkout()
        }
        
        let doneMenu = UIMenu(title: "Finish Workout", options: .displayInline, children: [saveWorkoutItem , deleteWorkoutItem])
        
        navigationItem.rightBarButtonItem?.menu = doneMenu
        
        if completedReps.count == 0 {
            noRepsFoundWarning()
        } else {
            completedSet = CompletedSet(completedReps: completedReps, currentWorkout: currentWorkout)
            adjustLayout()
            layoutScrollView()
            updateSetData()
            updateFeedbackData()
        }
    }
    
    func saveMeasuredWorkout() {
        var docData: [String: Any] = [:]
        if let completedSet = completedSet {
            docData = [
                "scheduledUniqueID": currentWorkout.uniqueID,
                "athleteName": currentWorkout.athleteName,
                "athleteFirst": currentWorkout.athleteFirst,
                "athleteLast": currentWorkout.athleteLast,
                "exercise": currentWorkout.exercise,
                "setNumber": currentWorkout.setNumber,
                "targetLoad": currentWorkout.targetLoad,
                "targetReps": completedReps.count,
                "targetVelocity": currentWorkout.targetVelocity,
                "weekOfYear": currentWorkout.weekOfYear,
                "weekYear": currentWorkout.weekYear,
                "setAverageVelocity": completedSet.averageVelocity,
                "setMaxVelocity": completedSet.maxVelocity,
                "setAveragePower": completedSet.averagePower,
                "setMaxPower": completedSet.maxPower,
                "setAverageTTP": completedSet.averageTTP,
                "setMaxTTP": completedSet.maxTTP
            ]
        } else {
            docData = [
                "scheduledUniqueID": currentWorkout.uniqueID,
                "athleteName": currentWorkout.athleteName,
                "athleteFirst": currentWorkout.athleteFirst,
                "athleteLast": currentWorkout.athleteLast,
                "exercise": currentWorkout.exercise,
                "setNumber": currentWorkout.setNumber,
                "targetLoad": currentWorkout.targetLoad,
                "targetReps": completedReps.count,
                "targetVelocity": currentWorkout.targetVelocity,
                "weekOfYear": currentWorkout.weekOfYear,
                "weekYear": currentWorkout.weekYear,
            ]
        }
        
        var docDataArrays: [String: Any] = [
            "scheduledUniqueID": currentWorkout.uniqueID
        ]
        
        print("Doc Data Size: \(getDocumentSize(data: docData))")
        print("Array Data Size: \(getDocumentSize(data: docDataArrays))")
        
        for repIndex in 0 ..< completedReps.count {
            docData["rep\(repIndex + 1)"] = [
                "repAverageVelocity": completedReps[repIndex].averageVelocity,
                "repMaxVelocity": completedReps[repIndex].maxVelocity,
                "repAveragePower": completedReps[repIndex].averagePower,
                "repMaxPower": completedReps[repIndex].maxPower,
                "repTTP": completedReps[repIndex].timeToPeak
            ]
            
            docDataArrays["rep\(repIndex + 1)"] = [
                "repVelocityArray": completedReps[repIndex].velocityArray,
                "repTimeArray": completedReps[repIndex].normalizedTimeArray
            ]
            
            print("Doc Data Size: \(getDocumentSize(data: docData))")
            print("Array Data Size: \(getDocumentSize(data: docDataArrays))")
        }

        var ref: DocumentReference? = nil
        ref = db.collection("athletes").document(currentTeamName).collection("completedWorkouts").addDocument(data: docData) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(ref!.documentID)")
            }
        }

        var refArray: DocumentReference? = nil
        refArray = db.collection("athletes").document(currentTeamName).collection("completedWorkoutArrays").addDocument(data: docDataArrays) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document Arrat added with ID: \(refArray!.documentID)")
            }
        }
    }
        
    func updateScheduledWorkout() {
        db.collection("athletes").document(currentTeamName).collection("scheduledWorkouts").document(currentWorkout.uniqueID).updateData([
            "targetReps": completedReps.count,
            "workoutCompleted": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
    
    func deleteMeasuredWorkout() {
        popToAthleteSelection()
    }
    
    func popToAthleteSelection() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            closeAppWarning()
        }
    }
    
    func closeAppWarning() {
        let dialogMessage = UIAlertController(title: "Error Deleting Workout!", message: "There was an issue deleting your workout from the queue. Please close the app and log in again. Your workout will be deleted upon closing the app.", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.navigationController?.popToViewController((self.navigationController?.viewControllers[2])!, animated: true)
         })
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func noRepsFoundWarning() {
        let dialogMessage = UIAlertController(title: "No Reps Measured!", message: "No reps were measured in the previous workout. Please select a new workout to begin tracking.", preferredStyle: .alert)
         let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
             self.navigationController?.popToViewController((self.navigationController?.viewControllers[2])!, animated: true)
          })
         dialogMessage.addAction(ok)
         self.present(dialogMessage, animated: true, completion: nil)
    }
    
    func analyzePartialReps(partialReps: [PartialCompetedRep]) {
        for rep in partialReps {
            let completeRep = CompletedRep(timeArray: rep.timeArray, velocityArray: rep.velocityArray, load: currentWorkout.targetLoad, targetVelocity: currentWorkout.targetVelocity)
            completedReps.append(completeRep)
        }
    }
    
    func dismissTrackerVC() {
        if let navigationController = self.navigationController {
            let navCount = navigationController.viewControllers.count
            if navCount > 4 {
                navigationController.viewControllers.remove(at: navCount - 2)
            }
        }
    }
    
    func updateFeedbackData() {
        var greenCount = 0
        var yellowCount = 0
        var redCount = 0
        
        for rep in completedReps {
            if rep.averageVelocity > currentWorkout.targetVelocity {
                greenCount += 1
            } else if rep.averageVelocity > (currentWorkout.targetVelocity - 5) {
                yellowCount += 1
            } else {
                redCount += 1
            }
        }
        
        greenTargetLabel.text = String(greenCount)
        yellowTargetLabel.text = String(yellowCount)
        redTargetLabel.text = String(redCount)
        
    }
    
    func createSlides() -> [RepSummarySlide] {
        for index in 0 ..< completedReps.count {
            let slide = Bundle.main.loadNibNamed("RepSummarySlide", owner: self, options: nil)?.first as! RepSummarySlide
            
            setVelocityGraph(completedRep: completedReps[index], chartView: slide.velocityGraphView)
            setPowerGraph(completedRep: completedReps[index], chartView: slide.powerGraphView)
            setRepStats(completedRep: completedReps[index], slide: slide, index: index)
            
            slides.append(slide)
        }
        return slides
    }
    
    func setVelocityGraph(completedRep: CompletedRep, chartView: LineChartView) {
        var yValuesVelocity: [ChartDataEntry] = []
        
        for index in completedRep.beginRepIndex ... completedRep.endRepIndex {
            let entryPoint = ChartDataEntry(x: completedRep.normalizedTimeArray[index], y: completedRep.velocityArray[index])
            yValuesVelocity.append(entryPoint)
        }
        
        let dataVelocity = setData(yValues: yValuesVelocity, color: K.colors.mainFont)
        chartView.data = dataVelocity
        
        formatLineGraph(chartView: chartView, color: K.colors.mainFont)
    }
    
    func setPowerGraph(completedRep: CompletedRep, chartView: LineChartView) {
        var yValuesPower: [ChartDataEntry] = []
        
        for index in 0 ..< completedRep.accelerationTimeArray.count {
            let entryPoint = ChartDataEntry(x: completedRep.accelerationTimeArray[index], y: Double(completedRep.powerArray[index]))
            yValuesPower.append(entryPoint)
        }
        
        let dataPower = setData(yValues: yValuesPower, color: K.colors.accentColor)
        chartView.data = dataPower
        
        formatLineGraph(chartView: chartView, color: K.colors.accentColor)
    }
    
    func setRepStats(completedRep: CompletedRep, slide: RepSummarySlide, index: Int) {
        let repAverageVelocityDouble = Double(completedRep.averageVelocity) / Double(100)
        slide.repAverageVelocity.text = String(format: "%.2f", repAverageVelocityDouble)
        let repMaxVelocityDouble = Double(completedRep.maxVelocity) / Double(100)
        slide.repMaxVelocity.text = String(format: "%.2f", repMaxVelocityDouble)
        slide.repAveragePower.text = String(completedRep.averagePower)
        slide.repMaxPower.text = String(completedRep.maxPower)
//        slide.projectedORM.text = String()
        slide.repTTP.text = String(format: "%.2f", completedRep.timeToPeak)
        
        
        if let image = UIImage(named: "number\(index+1)") {
            slide.repCountImage.image = image
        }
        if let tintColor = UIColor(named: partialCompletedReps[index].feedbackColor) {
            slide.repCountImage.tintColor = tintColor
        }
        
    }
    
    func setData(yValues: [ChartDataEntry], color: String) -> LineChartData {
        let set1 = LineChartDataSet(entries: yValues, label: nil)
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = false
        set1.lineWidth = 2
        set1.setColor(UIColor(named: color) ?? .systemRed)
        set1.fill = Fill(CGColor: (UIColor(named: color) ?? .systemRed).cgColor)
        set1.fillAlpha = 0.5
        set1.drawFilledEnabled = true
        set1.drawHorizontalHighlightIndicatorEnabled = false
        set1.drawVerticalHighlightIndicatorEnabled = false
        
        let data = LineChartData(dataSet: set1)
        data.setDrawValues(false)
        
        return data
    }
    
    func formatLineGraph(chartView: LineChartView, color: String) {
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        let yAxis = chartView.leftAxis
        
        yAxis.labelFont = .boldSystemFont(ofSize: 10)
        yAxis.setLabelCount(6, force: false)
        yAxis.labelTextColor = UIColor(named: color) ?? .systemRed
        yAxis.axisLineColor = UIColor(named: color) ?? .systemRed
        yAxis.labelPosition = .outsideChart
        
        chartView.xAxis.labelPosition = .bottom
        chartView.xAxis.labelFont = .boldSystemFont(ofSize: 10)
        chartView.xAxis.setLabelCount(6, force: false)
        chartView.xAxis.labelTextColor = UIColor(named: color) ?? .systemRed
        chartView.xAxis.axisLineColor = UIColor(named: color) ?? .systemRed
        
        chartView.backgroundColor = UIColor(named: K.colors.backgroundColor) ?? .systemRed
        chartView.drawGridBackgroundEnabled = false
        chartView.animate(xAxisDuration: 1.5)
    }
    
    func setUpScrollView(slides: [RepSummarySlide]) {
        scrollView.frame = CGRect(x: 0, y: scrollView.frame.minY, width: view.frame.width, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: 1.0)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height)
            
            scrollView.addSubview(slides[i])
        }
    }
    
    func adjustLayout() {
        headshotHeight.constant = view.bounds.height / 10
        headshotWidth.constant = view.bounds.height / 10
        
        headshotImage.asCircle()
        navigationItem.hidesBackButton = true
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * view.frame.width, y: 0), animated: true)
    }
    
    func layoutScrollView() {
        scrollView.delegate = self
        slides = createSlides()
        setUpScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubviewToFront(pageControl)
        pageControl.addTarget(self,
                              action: #selector(pageControlDidChange(_:)),
                              for: .valueChanged)
    }
    
    func updateSetData() {
        setExerciseLabel.text = currentWorkout.exercise
        setLoadLabel.text = "\(currentWorkout.targetLoad) lbs"
        let targetVelocityConversion = Double(currentWorkout.targetVelocity) / Double(100)
        setVelocityTargetLabel.text = String(format: "%.2f m/s", targetVelocityConversion)
        setNumberLabel.text = String(currentWorkout.setNumber)
        setRepsCompletedLabel.text = String(partialCompletedReps.count)
        firstNameLabel.text = currentWorkout.athleteFirst
        lastNameLabel.text = currentWorkout.athleteLast

        let averageVelocityConversion = Double(completedSet!.averageVelocity) / Double(100)
        averageVelocityLabel.text = String(format: "%.2f", averageVelocityConversion)
        let maxVelocityConversion = Double(completedSet!.maxVelocity) / Double(100)
        maxVelocityLabel.text = String(format: "%.2f", maxVelocityConversion)

        averagePowerLabel.text = String(completedSet!.averagePower)
        maxPowerLabel.text = String(completedSet!.maxPower)

        averageTTPLabel.text = String(format: "%.2f", completedSet!.averageTTP)
        maxTTPLabel.text = String(format: "%.2f", completedSet!.maxTTP)
    }
}

extension WorkoutSummaryViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.width)))
    }
    
    func getDocumentSize(data: [String : Any]) -> Int{
        var size = 0
        for (k, v) in  data {
            size += k.count + 1
            if let map = v as? [String : Any]{
                size += getDocumentSize(data: map)
            } else if let array = v as? [String]{
                for a in array {
                    size += a.count + 1
                }
            } else if let s = v as? String{
                size += s.count + 1
            }
        }
        return size
    }
}

extension UIImageView {
    func asCircle() {
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
}
