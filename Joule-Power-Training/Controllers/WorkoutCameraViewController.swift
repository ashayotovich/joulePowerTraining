//
//  WorkoutCameraViewController.swift
//  Joule-Power-Training
//
//  Created by Drew Shayotovich on 6/6/22.
//

import UIKit
import Firebase
import AVFoundation
import Vision
import SwiftUI

class WorkoutCameraViewController: UIViewController {

    var currentWorkout: ScheduledWorkout = ScheduledWorkout(uniqueID: "default", athleteName: "default", athleteFirst: "default", athleteLast: "default", exercise: "default", setNumber: 0, targetLoad: 0, targetReps: 0, targetVelocity: 0, week: Timestamp.init(date: Date.now), workoutCompleted: true)
    
    let feedbackImageArray: [UIImage] = [UIImage(named: K.feedbackImages.greenFilled)!, UIImage(named: K.feedbackImages.greenOpen)!, UIImage(named: K.feedbackImages.yellow)!, UIImage(named: K.feedbackImages.red)!, UIImage(named: K.feedbackImages.grey)!]
    
    @IBOutlet weak var repCounter: UILabel!
    @IBOutlet weak var repFeedbackImage: UIImageView!
    @IBOutlet weak var cameraView: UIView!
    
    let videoCapture = VideoCapture()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var pointsLayer = CAShapeLayer()
    let availableExercises = ["Squat"]
    let averageExercises = ["Squat"]
    
    var repCount: Int = 0
    var measuredShinLength: Double = 17
    var measuredShoulderWidth: Double?
    var repResults: ([Double], [Double], [Double]) = ([], [], [])
    var repValidation: ([Double], [Double], [Double]) = ([], [], [])
    var completedReps: [CompletedRep] = []
    
    var x0: Double = 0.0
    var y0: Double = 0.0
        
    var exerciseDetected = false
    
    //Debugging Variable
    var obsCounter: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if currentWorkout.workoutCompleted == true {
            navigationController?.popViewController(animated: true)
        } else {
            setupVideoPreview()
            videoCapture.predictor.delegate = self
            repFeedbackImage.asCircle()
        }
    }

    @IBAction func exitWorkoutPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    private func setupVideoPreview() {
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        
        guard let previewLayer = previewLayer else { return }

        cameraView.layer.addSublayer(previewLayer)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        
        cameraView.layer.addSublayer(pointsLayer)
        pointsLayer.frame = cameraView.bounds
        pointsLayer.strokeColor = UIColor.orange.cgColor
        pointsLayer.fillColor = UIColor.orange.cgColor
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WorkoutSummaryViewController
        
        destinationVC.completedReps = completedReps
        destinationVC.currentWorkout = currentWorkout
    }
}

extension WorkoutCameraViewController: PredictorDelegate {  
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double, during posesWindowUsed: [VNHumanBodyPoseObservation], atSpeed pixelVelocityFrame: [Double], atTime timeFrame: [TimeInterval]) {
        
        // DEBUGGING Variables
        let currentTime = Date()
        print(obsCounter)
        print("Action: \(action) with confidence: \(confidence) at \(currentTime.timeIntervalSince1970 - 1656258000)")
        //---------------------------------------------------------------------------;
        if availableExercises.contains(action) && confidence >= 0.95 && exerciseDetected == false {
            if action == "Squat" {
                let repValidation = predictor.squatValidation(firstObservation: posesWindowUsed[0], knownShinLength: measuredShinLength, rawTimeFrame: timeFrame, rawPixelVelocityFrame: pixelVelocityFrame)
            }
            
        }
        
        
        
//          DEPRECIATED CODE -----------
//        if availableExercises.contains(action) && confidence >= 0.95 && exerciseDetected == false {
//            if action == "Squat" {
//                repResults = predictor.squatAnalysis(observations: posesWindowUsed, knownShinLength: measuredShinLength ?? 17, knownShoulderWidth: measuredShoulderWidth ?? 16)
//                repResults.1 = repResults.1.map { $0.isNaN ? 0.0 : $0 }
//                // print("Velocity Window filtered: \(repResults.2)")
//            } // INSERT Other Exercises Analyses
//
//            // Rep Validation Round 1 - Window Size = 60 && > 1.1 m/s delta between Max and Min Velocity
//            if (repResults.2.max() ?? 0.0) - (repResults.2.min() ?? 0.0) > 1.1 && repResults.2.count == 59 {
//
//                //Rep Validation Round 2 - No delta velocity > 1.3 m/s from one frame to the next && Max Switchbacks < 15
//                var deltaVelocities: [Double] = []
//                var switchbacks: Int = 0
//
//                for velocityIndex in  1 ..< repResults.2.count {
//                    let delta = abs(repResults.2[velocityIndex] - repResults.2[velocityIndex - 1])
//                    deltaVelocities.append(delta)
//                    if repResults.2[velocityIndex] > 0 && repResults.2[velocityIndex - 1] < 0 {
//                        switchbacks += 1
//                    } else if repResults.2[velocityIndex] < 0 && repResults.2[velocityIndex - 1] > 0 {
//                        switchbacks += 1
//                    }
//                }
//
//                if (deltaVelocities.max() ?? Double(5.0)) < 1.3 {
//
//                    // Only Performed for Validated Rep -----------------------------------------------------
//                    exerciseDetected = true
//                    repCount += 1
//
//                    let newRep = CompletedRep(timeArray: repResults.0, velocityArray: repResults.2, load: currentWorkout.targetLoad, targetVelocity: currentWorkout.targetVelocity)
//
//                    if averageExercises.contains(action) {
//                        repFeedbackImage.image = feedbackImageArray[newRep.averageFeedbackImageIndex]
//                        print("Image Updted with averageImageIndex: \(newRep.averageFeedbackImageIndex)")
//                    } else {
//                        repFeedbackImage.image = feedbackImageArray[newRep.maxFeedbackImageIndex]
//                        print("Image Updted with maxImageIndex: \(newRep.maxFeedbackImageIndex)")
//                    }
//
//                    completedReps.append(newRep)
//
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                        self.exerciseDetected = false
//
//                        if self.repCount == self.currentWorkout.targetReps {
//                            self.performSegue(withIdentifier: K.segues.trackerToSummary, sender: self)
//                        }
//                    }
//
//
//                    // DEBUGGING Variables ---------------------------------------------
//                    print("Rep Count: \(repCount)")
//                    print("Rep Measured Velocities: \(repResults.1)")
//                    print("Rep Filtered Velocities: \(repResults.2)")
//                    print("Rep Timestamps: \(repResults.0)")
//                    print("Average Velocity: \(newRep.averageVelocity)")
//                    print("Max Velocity: \(newRep.maxVelocity)")
//                    print("TTP: \(newRep.timeToPeak)")
//                    print("Acceleration Array: \(newRep.accelerationArray)")
//                    print("Power Array: \(newRep.powerArray)")
//                    // -------------------------------------------------------------
//                    // Only Performed for Validated Rep -----------------------------------------------------
//                } else {
//                    // print("Rep Rejected, max step change: \(deltaVelocities.max() ?? 10.0), switchbacks: \(switchbacks)")
//                }
//            } else {
//                // print("Rep Rejected, max/min delta: \((repResults.2.max() ?? 0.0) - (repResults.2.min() ?? 0.0)), rep size: \(repResults.2.count), last velo: \(repResults.2.last ?? 10)")
//            }
//        }
        
        // DEBUGGING Variables
        obsCounter += 1
        // ------------------
        
    }
    
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint], body: VNHumanBodyPoseObservation) {
        
        guard let previewLayer = previewLayer else { return }

        let convertedPoints = points.compactMap {
            previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
        }
        
        let combinedPath = CGMutablePath()
        
        for point in convertedPoints {
            let dotPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width: 10, height: 10))
            dotPath.addLine(to: point)
            combinedPath.addPath(dotPath.cgPath)
        }
    
        pointsLayer.path = combinedPath

        DispatchQueue.main.async {
            self.pointsLayer.didChangeValue(for: \.path)
        }
    }
}

extension UIImageView {
    func asCircle() {
        self.layer.cornerRadius = self.frame.width / 2;
        self.layer.masksToBounds = true
    }
}
