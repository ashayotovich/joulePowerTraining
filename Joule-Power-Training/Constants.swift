//
//  Constants.swift
//  Joule-Power-Training
//
//  Created by Katie Jackson on 4/8/22.
//

struct K {
    
    struct segues {
        static let loginToSetup = "LoginToSetup"
        static let setupToAthleteSelection = "SetupToAthleteSelection"
        static let athleteSelectionToWorkoutTracker = "athleteSelectionToWorkoutTracker"
        static let errorNoWorkoutFound = "errorNoWorkoutFoundReturnToSelection"
        static let workoutSegue = "WorkoutSelectionToSummary"
        static let bleCellIdentifiler = "bleDeviceCell"
        static let trackerToSummary = "trackerToSummary"
    }
    
    struct tableCells {
        static let groupTableCell = "GroupTableCell"
        static let athleteTableCell = "AthleteTableCell"
    }
    
    struct colors {
        static let mainFont = "Color1-2"
        static let backgroundColor = "Color4-2"
        static let accentColor = "Color5"
        static let feedbackGreen = "feedbackGreen"
        static let feedbackYellow = "feedbackYellow"
        static let feedbackRed = "feedbackRed"
    }
    
    struct fonts {
        static let loginTextBoxes = "Helvetica Neue"
        static let workoutSelectionPicker = "Helvetica Neue"
    }
    
    struct flatIcons {
        static let finishWorkout = "checkmark.circle"
        static let exitWithoutSaving = "xmark.circle"
        static let logOut = "rectangle.portrait.and.arrow.right"
        
        static let saveWorkout = "checkmark.circle"
        static let deleteWorkout = "xmark.circle"
    }
}

