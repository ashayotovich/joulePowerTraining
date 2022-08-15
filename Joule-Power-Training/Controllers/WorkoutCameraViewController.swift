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

    // DEBUG CODE -----------------
    let repTime1: [Double] = [1659014947.6699228, 1659014947.718472, 1659014947.7637029, 1659014947.809602, 1659014947.855194, 1659014947.899193, 1659014947.946262, 1659014947.9928532, 1659014948.042784, 1659014948.08714, 1659014948.134373, 1659014948.180324, 1659014948.230173, 1659014948.275193, 1659014948.3204079, 1659014948.3694139, 1659014948.416548, 1659014948.463632, 1659014948.5127702, 1659014948.5596108, 1659014948.606453, 1659014948.6537309, 1659014948.699545, 1659014948.7449632, 1659014948.790474, 1659014948.837529, 1659014948.8874788, 1659014948.9338288, 1659014948.985299, 1659014949.0367799, 1659014949.086666, 1659014949.133727, 1659014949.1805549, 1659014949.228308, 1659014949.2742019, 1659014949.320837, 1659014949.3667278, 1659014949.413362, 1659014949.460053, 1659014949.511327, 1659014949.558461, 1659014949.605258, 1659014949.660943, 1659014949.710298, 1659014949.758074, 1659014949.805752, 1659014949.853253, 1659014949.899842, 1659014949.946301, 1659014949.991847, 1659014950.0381222, 1659014950.085474, 1659014950.13796, 1659014950.193523, 1659014950.249248, 1659014950.304667, 1659014950.3596349, 1659014950.4148068, 1659014950.469606, 1659014950.524823]
    let repVelo1: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.166446637,-0.37507644,-0.451073221,-0.527070003,-1.348097336,-1.820764981,-2.293432626,-2.039283974,-1.933073565,-1.826863156,-1.775979035,-1.446083782,-1.013419937,-0.581755863,0,0.437622513,0.990933125,1.544243736,1.545555316,1.546866897,1.562503967,1.599400832,1.765016642,1.504115843,1.417893076,1.33167031,1.079111424,0.826552538,0.162524866,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    let repTime2: [Double] = [1659014953.107835, 1659014953.16159, 1659014953.2170548, 1659014953.269977, 1659014953.3229918, 1659014953.375382, 1659014953.429762, 1659014953.483666, 1659014953.5363889, 1659014953.590506, 1659014953.643527, 1659014953.697607, 1659014953.75054, 1659014953.8031359, 1659014953.856217, 1659014953.9068708, 1659014953.9609509, 1659014954.014608, 1659014954.0683389, 1659014954.121402, 1659014954.1748009, 1659014954.228537, 1659014954.282565, 1659014954.335686, 1659014954.388914, 1659014954.4439979, 1659014954.498413, 1659014954.55135, 1659014954.604363, 1659014954.657944, 1659014954.711539, 1659014954.764431, 1659014954.818894, 1659014954.872042, 1659014954.9246612, 1659014954.978033, 1659014955.0307221, 1659014955.083883, 1659014955.137127, 1659014955.18877, 1659014955.2436008, 1659014955.297298, 1659014955.352181, 1659014955.4075751, 1659014955.461277, 1659014955.515857, 1659014955.570787, 1659014955.624603, 1659014955.675189, 1659014955.727632, 1659014955.781993, 1659014955.834587, 1659014955.886966, 1659014955.93897, 1659014955.98879, 1659014956.040029, 1659014956.0920439, 1659014956.144558, 1659014956.198412, 1659014956.250639]
    let repVelo2: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.190018336,-0.61810259,-0.950926837,-1.283751084,-1.499338493,-1.714925902,-1.761836431,-1.808746961,-2.09024093,-1.94348804,-1.796735149,-1.041216226,-0.422450787,0.701689677,0.891911692,1.082133706,2.568558458,1.891135759,1.782685431,1.748562459,1.714439487,1.701193756,1.34491639,0.988639024,0.623041129,0.257443234,0,0,0,0,0,0,0,0]

    let repTime3: [Double] = [1659014959.08117, 1659014959.135518, 1659014959.190799, 1659014959.245359, 1659014959.2984529, 1659014959.351708, 1659014959.4057221, 1659014959.459035, 1659014959.5086951, 1659014959.562006, 1659014959.615242, 1659014959.6689858, 1659014959.722758, 1659014959.776013, 1659014959.829527, 1659014959.88427, 1659014959.937069, 1659014959.9896731, 1659014960.043541, 1659014960.096209, 1659014960.150367, 1659014960.205069, 1659014960.258967, 1659014960.312882, 1659014960.365996, 1659014960.422025, 1659014960.475878, 1659014960.530532, 1659014960.5861669, 1659014960.6406589, 1659014960.694968, 1659014960.750849, 1659014960.8058271, 1659014960.8597279, 1659014960.913321, 1659014960.9685822, 1659014961.022297, 1659014961.078568, 1659014961.133208, 1659014961.187895, 1659014961.242634, 1659014961.297248, 1659014961.351606, 1659014961.406672, 1659014961.462068, 1659014961.5162559, 1659014961.571601, 1659014961.627739, 1659014961.6821342, 1659014961.738406, 1659014961.79467, 1659014961.848042, 1659014961.893591, 1659014961.938816, 1659014961.982647, 1659014962.028424, 1659014962.073772, 1659014962.121976, 1659014962.168126, 1659014962.21292]
    let repVelo3: [Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-0.533012594,-0.915263783,-1.297514973,-1.463607022,-1.62969907,-2.12148377,-1.921659297,-1.824050634,-1.818436202,-1.812821769,-1.737332417,-1.411448638,-1.085564859,-0.362967988,0.23335839,0.302968707,1.932836425,2.263402832,2.593969239,1.802180653,1.500347948,1.198515242,1.141599378,1.084683513,0.994956408,0.904349623,0.813742838,0.455481778,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

    // DEBUG CODE -----------------
    
    var currentWorkout: ScheduledWorkout = ScheduledWorkout(uniqueID: "default", athleteName: "default", athleteFirst: "default", athleteLast: "default", exercise: "default", setNumber: 0, targetLoad: 0, targetReps: 0, targetVelocity: 0, weekOfYear: 0, weekYear: 0, workoutCompleted: true)
    
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
    var repValidation: ([Double], [Double], [Double], [Double], [Double], Bool) = ([], [], [], [], [], false)
    var partialCompletedReps: [PartialCompetedRep] = []
    var workoutEndedBool: Bool = false
    
    var x0: Double = 0.0
    var y0: Double = 0.0
        
    var exerciseDetected = false
    
    //Debugging Variable
    var obsCounter: Int = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        
        // Debug Code -------------------
        partialCompletedReps = [PartialCompetedRep(timeArray: repTime1, velocityArray: repVelo1, targetVelocity: currentWorkout.targetVelocity), PartialCompetedRep(timeArray: repTime2, velocityArray: repVelo2, targetVelocity: currentWorkout.targetVelocity), PartialCompetedRep(timeArray: repTime3, velocityArray: repVelo3, targetVelocity: currentWorkout.targetVelocity)]

        if partialCompletedReps.count == currentWorkout.targetReps {
            performSegue(withIdentifier: "trackerToSummary", sender: self)
        }
        // Debug Code -------------------
        
        if currentWorkout.workoutCompleted == true {
            navigationController?.popViewController(animated: true)
        } else {
            setupVideoPreview()
            videoCapture.predictor.delegate = self
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
        pointsLayer.strokeColor = UIColor.black.cgColor
        pointsLayer.fillColor = UIColor.black.cgColor
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! WorkoutSummaryViewController
        
        destinationVC.currentWorkout = currentWorkout
        destinationVC.partialCompletedReps = partialCompletedReps
        

    }
}

extension WorkoutCameraViewController: PredictorDelegate {  
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double, during posesWindowUsed: [VNHumanBodyPoseObservation], atSpeed pixelVelocityFrame: [Double], atTime timeFrame: [TimeInterval]) {
        
        // DEBUGGING Variables
        let currentTime = Date()
        print(obsCounter)
        print("Action: \(action) with confidence: \(confidence) at \(currentTime.timeIntervalSince1970 - 1659000000)")
        //---------------------------------------------------------------------------;
        
        if availableExercises.contains(action) && confidence >= 0.92 && exerciseDetected == false {
            if action == "Squat" {
                let repValidation = predictor.squatValidation(firstObservation: posesWindowUsed[0], knownShinLength: measuredShinLength, rawTimeFrame: timeFrame, rawPixelVelocityFrame: pixelVelocityFrame)

                if repValidation.2 {
                    repCount += 1
                    exerciseDetected = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        self.exerciseDetected = false
                    }
                    
                    let partialRep = PartialCompetedRep(timeArray: repValidation.0, velocityArray: repValidation.1, targetVelocity: currentWorkout.targetVelocity)
                    partialCompletedReps.append(partialRep)
                    print("Rep Count: \(repCount)")
                    print("Rep Time: \(repValidation.0)")
                    print("Smoothed Velocity: \(repValidation.1)")
                    
                }
            }
            
            if repCount == currentWorkout.targetReps {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "trackerToSummary", sender: self)
                }
            }
        }
        
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


