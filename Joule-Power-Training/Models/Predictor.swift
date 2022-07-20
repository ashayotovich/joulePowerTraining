//
//  Predictor.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 6/16/22.
//

import Foundation
import Vision

typealias WorkoutClassifier = WorkoutClassifier_3

protocol PredictorDelegate: AnyObject {
    func predictor(_ predictor: Predictor, didFindNewRecognizedPoints points: [CGPoint], body: VNHumanBodyPoseObservation)
    func predictor(_ predictor: Predictor, didLabelAction action: String, with confidence: Double, during posesWindowUsed: [VNHumanBodyPoseObservation], atSpeed pixelVelocityFrame: [Double], atTime timeFrame: [TimeInterval])
}

class Predictor {
    
    weak var delegate: PredictorDelegate?
    
    var timeWindow: [Double] = []
    var xPixelWindow: [Double] = []
    var xMeterWindow: [Double] = []
    var yPixelWindow: [Double] = []
    var yMeterWindow: [Double] = []
    var velocityWindow: [Double] = []
    
    var x: Double = 0.0
    var y: Double = 0.0
    // New Method ---------------------------
    let predictionWindowSize = 60
    var posesWindow: [VNHumanBodyPoseObservation] = []
    var posLeft0: Double = 0.0
    var posRight0: Double = 0.0
    var time0 = Date().timeIntervalSince1970
    var time1 = Date().timeIntervalSince1970
    var posLeft1: Double = 0.0
    var posRight1: Double = 0.0
    var pixelInstantVelocity: Double = 0.0
    var instantVelocity: Double = 0.0
    
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
            
            var deltaLeft = posLeft1 - posLeft0
            var deltaRight = posRight1 - posRight0
            
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
            
            // DEBUG -------------------------------------------------------------
//            yLElbow1 = try observation.recognizedPoint(.leftElbow).x
//            yRElbow1 = try observation.recognizedPoint(.rightElbow).x
//            yLShoulder1 = try observation.recognizedPoint(.leftShoulder).x
//            yRShoulder1 = try observation.recognizedPoint(.rightShoulder).x
//            yLWrist1 = try observation.recognizedPoint(.leftWrist).x
//            yRWrist1 = try observation.recognizedPoint(.rightWrist).x
//            debugTime1 = Date().timeIntervalSince1970
//
//            let deltaLElbow = yLElbow1 - yLElbow0
//            let deltaRElbow = yRElbow1 - yRElbow0
//            let deltaLShoulder = yLShoulder1 - yLShoulder0
//            let deltaRShoulder = yRShoulder1 - yRShoulder0
//            let deltaLWrist = yLWrist1 - yLWrist0
//            let deltaRWrist = yRWrist1 - yRWrist0
//            let deltaDebugTime = debugTime1 - debugTime0
//
//            velLElbow = deltaLElbow / deltaDebugTime
//            velRElbow = deltaRElbow / deltaDebugTime
//            velLShoulder = deltaLShoulder / deltaDebugTime
//            velRShoulder = deltaRShoulder / deltaDebugTime
//            velLWrist = deltaLWrist / deltaDebugTime
//            velRWrist = deltaRWrist / deltaDebugTime
//
//            print("Time, Position, Pixel/s: \(debugTime1), \(yLElbow1), \(yRElbow1), \(yLShoulder1), \(yRShoulder1), \(yLWrist1), \(yRWrist1), \(velLElbow), \(velRElbow), \(velLShoulder), \(velRShoulder), \(velLWrist), \(velRWrist)")
//
//            yLElbow0 = yLElbow1
//            yRElbow0 = yRElbow1
//            yLShoulder0 = yLShoulder1
//            yRShoulder0 = yRShoulder1
//            yLWrist0 = yLWrist1
//            yRWrist0 = yRWrist1
//            
            // DEBUG -------------------------------------------------------------

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
        
        // DEBUG if needed
//        print("Left Knee X: \(leftKneeX)")
//        print("Left Knee Y: \(leftKneeY)")
//        print("Left Ankle X: \(leftAnkleX)")
//        print("Left Ankle Y: \(leftAnkleY)")
//        print("Left Shin Angle: \(leftShinAngle)")
//        print("Right Knee X: \(rightKneeX)")
//        print("Right Knee Y: \(rightKneeY)")
//        print("Right Ankle X: \(rightAnkleX)")
//        print("Right Ankle Y: \(rightAnkleY)")
//        print("Right Shin Angle: \(rightShinAngle)")
//        print("Vertical Conversion Factor: \(verticalPixelToMeterFactor)")
        
        return verticalPixelToMeterFactor
    }

    
    //MARK: - Exercise Analyses/Validation

    func squatValidation(firstObservation: VNHumanBodyPoseObservation, knownShinLength: Double, rawTimeFrame: [TimeInterval], rawPixelVelocityFrame: [Double]) -> ([Double], [Double], [Double], [Double], [Double], Bool) {
        
        // Returns [Timestamp], [rawPixelVelocity], [convertedVelocity (m/s)], [smoothVelocity1], [smoothVelocity2], Bool
        let conversionFactor = calculatePixelRatio(body: firstObservation, knownShinLength: knownShinLength)
        
        var convertedVelocityFrame: [Double] = []
        var smoothedVelocityFrame1: [Double] = []
        var smoothedVelocityFrame2: [Double] = []
        
        for pixelVelocity in pixelVelocityFrame {
            let convertedVelocity = pixelVelocity * conversionFactor
            convertedVelocityFrame.append(convertedVelocity)
        }
        
        var k = 1
        smoothedVelocityFrame1.append(convertedVelocityFrame[0])
        var filterCounterK = 0
        while k < convertedVelocityFrame.count - 1 {
            var currentVelocity = convertedVelocityFrame[k]
            if currentVelocity < 0 {
                if currentVelocity > convertedVelocityFrame[k-1] && currentVelocity > convertedVelocityFrame[k+1] {
                    currentVelocity = (convertedVelocityFrame[k-1] + convertedVelocityFrame[k+1]) / 2
                    filterCounterK += 1
                }
            } else {
                if currentVelocity < convertedVelocityFrame[k-1] && currentVelocity < convertedVelocityFrame[k+1] {
                    currentVelocity = (convertedVelocityFrame[k-1] + convertedVelocityFrame[k+1]) / 2
                    filterCounterK += 1
                }
            }
            
            smoothedVelocityFrame1.append(currentVelocity)
            k += 1
        }
        
        var j = 1
        smoothedVelocityFrame2.append(smoothedVelocityFrame1[0])
        var filterCounterJ = 0
        while j < smoothedVelocityFrame1.count - 1 {
            var currentVelocity = smoothedVelocityFrame1[j]
            if currentVelocity < 0 {
                if currentVelocity > smoothedVelocityFrame1[j-1] && currentVelocity > smoothedVelocityFrame1[j+1] {
                    currentVelocity = (smoothedVelocityFrame1[j-1] + smoothedVelocityFrame1[j+1]) / 2
                    filterCounterJ += 1
                }
            } else {
                if currentVelocity < smoothedVelocityFrame1[j-1] && currentVelocity < smoothedVelocityFrame1[j+1] {
                        currentVelocity = (smoothedVelocityFrame1[j-1] + smoothedVelocityFrame1[j+1]) / 2
                        filterCounterJ += 1
                }
            }
            
            smoothedVelocityFrame2.append(currentVelocity)
            j += 1
        }
        
        if smoothedVelocityFrame2.count == 59 {
            if abs((smoothedVelocityFrame2.max() ?? 0.0) - (smoothedVelocityFrame2.min() ?? 0.0)) > 1.1 {
                shouldCountRep = true
            } else {
                print("Vmax - Vmin < 1.1 m/s: \(abs((smoothedVelocityFrame2.max() ?? 0.0) - (smoothedVelocityFrame2.min() ?? 0.0)))")
                shouldCountRep = false
            }
        } else {
            print("Final frame size != 59: \(smoothedVelocityFrame2.count)")
            shouldCountRep = false
        }
        return (rawTimeFrame, rawPixelVelocityFrame, convertedVelocityFrame, smoothedVelocityFrame1, smoothedVelocityFrame2, shouldCountRep)
    }
  
    
        // DEPRECIATED CODE
    // ---------------------------------
//    func squatAnalysis(observations: [VNHumanBodyPoseObservation], knownShinLength: Double?, knownShoulderWidth: Double?) -> ([Double], [Double], [Double]) {
//        velocityWindow = [0.0]
//        var xMeterWindow: [Double] = []
//        var yMeterWindow: [Double] = []
//
//        let conversionFactors = calculatePixelRatio(body: observations[0], knownShinLength: (knownShinLength ?? 17), knownShoulderWidth: (knownShoulderWidth ?? 16))
//        let horizontalConversionFactor = conversionFactors[0]
//        let verticalConversionFactor = conversionFactors[1]
//
//        for position in yPixelWindow {
//            let meterPositionVertical = position * verticalConversionFactor
//            yMeterWindow.append(meterPositionVertical)
//        }
//
//        for position in xPixelWindow {
//            let meterPositionHorizontal = position * horizontalConversionFactor
//            xMeterWindow.append(meterPositionHorizontal)
//        }
//
//        var i = 1
//        var verticalPosition0 = yMeterWindow[0]
//        var horizontalPosition0 = xMeterWindow[0]
//        var t0 = timeWindow[0]
//        var velocitiesMeasured: [Double] = []
//        var verticalDeltas: [Double] = []
//        var horizontalDeltas: [Double] = []
//        var signFactor = 1.0
//
//        while i < min(observations.count, predictionWindowSize) {
//            let verticalPosition1 = yMeterWindow[i]
//            let horizontalPosition1 = xMeterWindow[i]
//            let t1 = timeWindow[i]
//
//            var deltaVerticalPosition = verticalPosition1 - verticalPosition0
//            var deltaHorizontalPosition = horizontalPosition1 - horizontalPosition0
//            let deltaTime = t1 - t0
//
//
//            if deltaVerticalPosition < 0 {
//                signFactor = -1.0
//            } else {
//                signFactor = 1.0
//            }
//
//            if abs(deltaVerticalPosition) > 0.1 || abs(deltaVerticalPosition - (verticalDeltas.last ?? 0.0)) > 0.05 {
//                deltaVerticalPosition = verticalDeltas.last ?? 0.0
////                print("deltaVertical filtered")
//            }
//
//            if abs(deltaHorizontalPosition) > 0.015 || abs(deltaHorizontalPosition - (horizontalDeltas.last ?? 0.0)) > 0.02 {
//                deltaHorizontalPosition = horizontalDeltas.last ?? 0.0
////                print("deltaHorizontal filtered")
//            }
//
//            // Deltas are in METERS
//            verticalDeltas.append(deltaVerticalPosition)
//            horizontalDeltas.append(deltaHorizontalPosition)
//
//            let distanceTraveledMeters = hypot(deltaVerticalPosition, deltaHorizontalPosition)
//            let velocityMetersPerSecond = signFactor * distanceTraveledMeters / deltaTime
//            velocitiesMeasured.append(velocityMetersPerSecond)
//
//            verticalPosition0 = verticalPosition1
//            horizontalPosition0 = horizontalPosition1
//            t0 = t1
//            i = i + 1
//        }
//
//        var timeDeltas: [Double] = []
//        for t in timeWindow {
//            let time = t - timeWindow[0]
//            timeDeltas.append(time)
//        }
//        //MARK: - Measured Velocity Filtering
//
//        var k = 1
//        var velocitiesCorrected: [Double] = []
//        velocitiesCorrected.append(velocitiesMeasured[0])
//        var filterCounterK = 0
//        while k < velocitiesMeasured.count - 1 {
//            var currentVelocity = velocitiesMeasured[k]
//            if currentVelocity < 0 {
//                if currentVelocity > velocitiesCorrected[k-1] && currentVelocity > velocitiesMeasured[k+1] {
//                    currentVelocity = (velocitiesCorrected[k-1] + velocitiesMeasured[k+1]) / 2
//                    filterCounterK += 1
//                }
//            } else {
//                if currentVelocity < velocitiesCorrected[k-1] && currentVelocity < velocitiesMeasured[k+1] {
//                    currentVelocity = (velocitiesCorrected[k-1] + velocitiesMeasured[k+1]) / 2
//                    filterCounterK += 1
//                }
//            }
//
//            velocitiesCorrected.append(currentVelocity)
//            k += 1
//        }
//
//        var b = 1
//        var filterCounterB = 0
//        while b < velocitiesCorrected.count - 1 {
//            var currentVelocity = velocitiesCorrected[b]
//            if currentVelocity < 0 {
//                if currentVelocity > velocitiesCorrected[b-1] && currentVelocity > velocitiesCorrected[b+1] {
//                    currentVelocity = (velocitiesCorrected[b-1] + velocitiesCorrected[b+1]) / 2
//                    filterCounterB += 1
//                }
//            } else {
//                if currentVelocity < velocitiesCorrected[b-1] && currentVelocity < velocitiesCorrected[b+1] {
//                    currentVelocity = (velocitiesCorrected[b-1] + velocitiesCorrected[b+1]) / 2
//                    filterCounterB += 1
//                }
//            }
//
//            velocitiesCorrected[b] = currentVelocity
//            b += 1
//        }
//        velocitiesCorrected.append(velocitiesMeasured.last ?? 0.0)
//
//        return (timeDeltas, velocitiesMeasured, velocitiesCorrected)
//    }
}
