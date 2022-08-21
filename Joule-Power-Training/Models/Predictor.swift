//
//  Predictor.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 6/16/22.
//

import Foundation
import Vision
import SwiftUI

typealias WorkoutClassifier = WorkoutClassifier_3

protocol PredictorDelegate: AnyObject {
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint], body: VNHumanBodyPoseObservation)
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double, during posesWindowUsed: [VNHumanBodyPoseObservation], atSpeed pixelVelocityFrame: [Double], atTime timeFrame: [TimeInterval])
}

class Predictor {
    
    weak var delegate: PredictorDelegate?
    
    // New Method ---------------------------
    let predictionWindowSize = 60
    var posLeft0: Double = 0.0
    var posRight0: Double = 0.0
    var time0 = Date().timeIntervalSince1970
    var time1 = Date().timeIntervalSince1970
    var posLeft1: Double = 0.0
    var posRight1: Double = 0.0
    var pixelInstantVelocity: Double = 0.0
    var instantVelocity: Double = 0.0
    var minVelocityIndex: Int = 0
    var maxVelocityIndex: Int = 0
    var posesWindow: [VNHumanBodyPoseObservation] = []
    var pixelVelocityFrame: [Double] = []
    var timeFrame: [TimeInterval] = []
    
    var shouldStoreObservation: Bool = true
    var shouldCountRep: Bool = false
    
    //DEBUG ----------------------
    var yLShoulder0: Double = 0.0
    var yLShoulder1: Double = 0.0
    var yRShoulder0: Double = 0.0
    var yRShoulder1: Double = 0.0
    var yLElbow0: Double = 0.0
    var yLElbow1: Double = 0.0
    var yRElbow0: Double = 0.0
    var yRElbow1: Double = 0.0
    var yLWrist0: Double = 0.0
    var yLWrist1: Double = 0.0
    var yRWrist0: Double = 0.0
    var yRWrist1: Double = 0.0
    
    var debugTime0 = Date().timeIntervalSince1970
    var debugTime1 = Date().timeIntervalSince1970
    
    var velLShoulder: Double = 0.0
    var velRShoulder: Double = 0.0
    var velLElbow: Double = 0.0
    var velRElbow: Double = 0.0
    var velLWrist: Double = 0.0
    var velRWrist: Double = 0.0
    
    //DEBUG ----------------------
    
    init() {
        posesWindow.reserveCapacity(predictionWindowSize)

    }
    
    func estimation(sampleBuffer: CMSampleBuffer) {
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up)
        
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)
        
        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request with error: \(error)")
        }
    }
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        observations.forEach {
            processObservation($0)
        }
        
        if let result = observations.first {
            
            storeObservation(result, time1: time1, pixelVelocity: pixelInstantVelocity, shouldStoreObservation: shouldStoreObservation)
            labelActionType()
        }
    }
    
    func labelActionType() {
        guard let workoutClassifier = try? WorkoutClassifier(configuration: MLModelConfiguration()),
              let exerciseMultiArray = prepareInputWithObservations(posesWindow),
              let predictions = try? workoutClassifier.prediction(poses: exerciseMultiArray)
        else { return }
        
        let label = predictions.label
        let confidence = predictions.labelProbabilities[label] ?? 0
        
        delegate?.predictor(self, didLabelAction: label, with: confidence, during: posesWindow, atSpeed: pixelVelocityFrame, atTime: timeFrame)
    }
    
    func prepareInputWithObservations(_ observations: [VNHumanBodyPoseObservation]) -> MLMultiArray? {
        let numAvailableFrames = observations.count
        let observationsNeeded = 60
        var multiArrayBuffer = [MLMultiArray]()
        
        for frameIndex in 0 ..< min(numAvailableFrames, observationsNeeded) {
            let pose = observations[frameIndex]
            do {
                let oneFramMultiArray = try pose.keypointsMultiArray()
                multiArrayBuffer.append(oneFramMultiArray)
            } catch {
                continue
            }
        }
        
        if numAvailableFrames < observationsNeeded {
            for _ in 0 ..< (observationsNeeded - numAvailableFrames) {
                do {
                    let oneFrameMultiArray = try MLMultiArray(shape: [1, 3, 18], dataType: .double)
                    try resetMultiArray(oneFrameMultiArray)
                    multiArrayBuffer.append(oneFrameMultiArray)
                } catch {
                    continue
                }
            }
        }
        
        return MLMultiArray(concatenating: [MLMultiArray](multiArrayBuffer), axis: 0, dataType: .float)
    }
    
    func resetMultiArray(_ predictionWindow: MLMultiArray, with value: Double = 0.0) throws {
        let pointer = try UnsafeMutableBufferPointer<Double>(predictionWindow)
        pointer.initialize(repeating: value)
    }
    
    func storeObservation(_ observation: VNHumanBodyPoseObservation, time1: TimeInterval, pixelVelocity: Double, shouldStoreObservation: Bool) {
        
        if shouldStoreObservation {
            if posesWindow.count >= predictionWindowSize {
                posesWindow.removeFirst()
                pixelVelocityFrame.removeFirst()
                timeFrame.removeFirst()
                
                posesWindow.append(observation)
                pixelVelocityFrame.append(pixelVelocity)
                timeFrame.append(time1)
                
            } else {
                posesWindow.append(observation)
                pixelVelocityFrame.append(pixelVelocity)
                timeFrame.append(time1)
            }
        }
    }
    
    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        do {
            let recognizedPoints = try observation.recognizedPoints(forGroupKey: .all)
            
            posLeft1 = try observation.recognizedPoint(.leftWrist).x
            posRight1 = try observation.recognizedPoint(.rightWrist).x
            time1 = Date().timeIntervalSince1970
            
            if posLeft1 != Double(0) || posRight1 != Double(0) {
                shouldStoreObservation = true
                
                if posLeft1 == Double(0) {
                    posLeft1 = posRight1
                } else if posRight1 == Double(0) {
                    posRight1 = posLeft1
                }
            } else {
                shouldStoreObservation = false
            }
            
            if posLeft1 != Double(1) || posRight1 != Double(1) {
                shouldStoreObservation = true
                if posLeft1 == Double(1) {
                    posLeft1 = posRight1
                } else if posRight1 == Double(1) {
                    posRight1 = posLeft1
                }
            } else {
                shouldStoreObservation = false
            }
            
            var deltaLeft = -1 * (posLeft1 - posLeft0)
            var deltaRight = -1 * (posRight1 - posRight0)
            
            if abs(deltaLeft) < 0.08 || abs(deltaRight) < 0.08 {
                shouldStoreObservation = true
                if abs(deltaLeft) > 0.08 {
                    deltaLeft = deltaRight
                } else if abs(deltaRight) > 0.08 {
                    deltaRight = deltaLeft
                }
            } else {
                shouldStoreObservation = false
            }
            
            let averageDelta = (deltaLeft + deltaRight) / 2
            let timeDelta = time1 - time0
            
            pixelInstantVelocity = averageDelta / timeDelta
            
            posLeft0 = posLeft1
            posRight0 = posRight1
            time0 = time1

            let displayedPoints = recognizedPoints.map {
                CGPoint(x: $0.value.x, y: 1 - $0.value.y)
            }
            
            delegate?.predictor(self, didFindNewRecognizedPoints: displayedPoints, body: observation)
        } catch {
            print("error finding recognizedPoints")
        }
    }
    
    //MARK: - Analysis Helper Functions
//    func calculatePixelsTraveled(x: Double, y: Double) -> Double {
//        let pixelsTraveled = hypot(x, y)
//        return pixelsTraveled
//    }

    func calculatePixelRatio(body: VNHumanBodyPoseObservation, knownShinLength: Double) -> Double {
        // Returns conversion factors in terms of meters/pixels
        guard let leftKneeX = try? body.recognizedPoint(.leftKnee).x,
              let leftKneeY = try? body.recognizedPoint(.leftKnee).y,
              let rightKneeX = try? body.recognizedPoint(.rightKnee).x,
              let rightKneeY = try? (body.recognizedPoint(.rightKnee).y),
              let leftAnkleX = try? body.recognizedPoint(.leftAnkle).x,
              let leftAnkleY = try? body.recognizedPoint(.leftAnkle).y,
              let rightAnkleX = try? body.recognizedPoint(.rightAnkle).x,
              let rightAnkleY = try? (body.recognizedPoint(.rightAnkle).y)

        else { return Double(17 / 0.0254 / 0.2) }

        let leftShinDeltaX = abs(leftKneeY - leftAnkleY)
        let leftShinDeltaY = abs(leftKneeX - leftAnkleX)
        let leftShinAngle = atan(leftShinDeltaX / leftShinDeltaY)
        let leftShinDeltaYMeters = cos(leftShinAngle) * (knownShinLength) * 0.0254
        let leftVerticalPixelToMeterFactor = leftShinDeltaYMeters / leftShinDeltaY

        let rightShinDeltaX = abs(rightKneeY - rightAnkleY)
        let rightShinDeltaY = abs(rightKneeX - rightAnkleX)
        let rightShinAngle = atan(rightShinDeltaX / rightShinDeltaY)
        let rightShinDeltaYMeters = cos(rightShinAngle) * (knownShinLength) * 0.0254
        let rightVerticalPixelToMeterFactor = rightShinDeltaYMeters / rightShinDeltaY

        var verticalPixelToMeterFactor = (rightVerticalPixelToMeterFactor + leftVerticalPixelToMeterFactor) / 2.0

        // Value is conversion factor in terms of METERS / PIXELS
        
        if verticalPixelToMeterFactor.isNaN {
            verticalPixelToMeterFactor = 2.6
        }
        
        return verticalPixelToMeterFactor
    }
    
    func smoothCurveOut(velocityCurve: [Double]) -> ([Double], Bool) {
        var smoothCurveBool = false
        var editableVelocityCurve = velocityCurve
        
        for velocityIndex in 0 ..< editableVelocityCurve.count {
            if abs(editableVelocityCurve[velocityIndex]) < 0.13 {
                editableVelocityCurve[velocityIndex] = 0.0
            }
        }
        
        var smoothAttempts = 0
        while smoothCurveBool == false {
            var k = 1
            var filterCounter = 0
            while k < velocityCurve.count - 1 {
                var currentVelocity = editableVelocityCurve[k]
                if currentVelocity < 0 {
                    if currentVelocity > editableVelocityCurve[k-1] && currentVelocity > editableVelocityCurve[k+1] {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    } else if editableVelocityCurve[k-1] > 0 && editableVelocityCurve[k+1] > 0 {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    }
                } else if currentVelocity > 0 {
                    if currentVelocity < editableVelocityCurve[k-1] && currentVelocity < editableVelocityCurve[k+1] {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    } else if editableVelocityCurve[k-1] < 0 && editableVelocityCurve[k+1] < 0 {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    }
                } else {
                    if editableVelocityCurve[k-1] > 0 && editableVelocityCurve[k+1] > 0 {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    } else if editableVelocityCurve[k-1] < 0 && editableVelocityCurve[k+1] < 0 {
                        currentVelocity = (editableVelocityCurve[k-1] + editableVelocityCurve[k+1]) / 2
                        filterCounter += 1
                    }
                }
                
                editableVelocityCurve[k] = currentVelocity
                k += 1
            }
            print("Filter Count: \(filterCounter)")
            smoothAttempts += 1
            
            if filterCounter <= 3 {
                smoothCurveBool = true
            } else if smoothAttempts > 20 {
                smoothCurveBool = false
                print("Too many smooth attempts; still \(filterCounter) remain")
                print("Leftover curve: \(editableVelocityCurve)")
                return (editableVelocityCurve, smoothCurveBool)
            }
        }
        return (editableVelocityCurve, smoothCurveBool)
    }


    
    //MARK: - Exercise Analyses/Validation

    func squatValidation(firstObservation: VNHumanBodyPoseObservation, knownShinLength: Double, rawTimeFrame: [TimeInterval], rawPixelVelocityFrame: [Double]) -> ([Double], [Double], Bool) {
        
        // Returns [Timestamp], [smoothVelocity1], Bool
        let conversionFactor = calculatePixelRatio(body: firstObservation, knownShinLength: knownShinLength)
        
        var convertedVelocityFrame: [Double] = []
        var smoothedVelocityFrame: [Double] = []
        
        for pixelVelocity in pixelVelocityFrame {
            let convertedVelocity = pixelVelocity * conversionFactor
            convertedVelocityFrame.append(convertedVelocity)
        }
        
        let filteredVelocity = smoothCurveOut(velocityCurve: convertedVelocityFrame)
        smoothedVelocityFrame = filteredVelocity.0
        let smoothValidation: Bool = filteredVelocity.1
        let lastVelocity: Double = smoothedVelocityFrame.last ?? Double(5)
        
        if smoothValidation == false || lastVelocity > 0.3 {
            shouldCountRep = false
            print("smoothFalse or \(lastVelocity)")
            return (rawTimeFrame, smoothedVelocityFrame, shouldCountRep)
        } else {
            
            if let maxVelocity = smoothedVelocityFrame.max(), let minVelocity = smoothedVelocityFrame.min() {
                
                minVelocityIndex = smoothedVelocityFrame.firstIndex(of: minVelocity) ?? 0
                maxVelocityIndex = smoothedVelocityFrame.firstIndex(of: maxVelocity) ?? 0
            }
            
            if convertedVelocityFrame.count == 60 {
                if abs((smoothedVelocityFrame.max() ?? 0.0) - (smoothedVelocityFrame.min() ?? 0.0)) > 1.1 {
                    if maxVelocityIndex > minVelocityIndex {
                        shouldCountRep = true
                        print("Smooth Curve: \(smoothedVelocityFrame)")
                    } else {
                        print("Minimum Velocity Index (\(minVelocityIndex)) >= Maximum Velocity Index (\(maxVelocityIndex))")
                        shouldCountRep = false
                    }
                } else {
                    print("Vmax - Vmin < 1.1 m/s: \(abs((smoothedVelocityFrame.max() ?? 0.0) - (smoothedVelocityFrame.min() ?? 0.0)))")
                    shouldCountRep = false
                }
            } else {
                print("Final frame size != 60: \(smoothedVelocityFrame.count)")
                shouldCountRep = false
            }
            
            return (rawTimeFrame, smoothedVelocityFrame, shouldCountRep)
        }
    }
}
