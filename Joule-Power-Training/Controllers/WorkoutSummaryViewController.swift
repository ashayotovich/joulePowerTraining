//
//  WorkoutSummaryViewController.swift
//  Joule-Power-Training
//
//  Created by Drew Shayotovich on 4/24/22.
//

import UIKit
import Firebase
import SwiftUI

class WorkoutSummaryViewController: UIViewController, UIScrollViewDelegate {
    
    // Variables from Previous Segue
    var currentWorkout: ScheduledWorkout = ScheduledWorkout(uniqueID: "default", athleteName: "default", athleteFirst: "default", athleteLast: "default", exercise: "default", setNumber: 0, targetLoad: 0, targetReps: 0, targetVelocity: 0, weekOfYear: 0, weekYear: 0, workoutCompleted: true)
    var completedReps: [CompletedRep] = []
    
    var slides: [RepSummarySlide] = []
    let imageArray: [UIImage] = [UIImage(named: K.feedbackImages.greenFilled)!, UIImage(named: K.feedbackImages.greenOpen)!, UIImage(named: K.feedbackImages.yellow)!, UIImage(named: K.feedbackImages.red)!, UIImage(named: K.feedbackImages.grey)!]
    
    @IBOutlet weak var athleteAndWorkoutInfoView: UIView!
    @IBOutlet weak var setAndVelocityView: UIView!
    @IBOutlet weak var setView: UIView!
    @IBOutlet weak var velocityView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var repSummaryLabelView: UIView!
    @IBOutlet weak var setFeedbackView: UIView!
    
    @IBOutlet weak var separatorView: UIView!
    
    @IBOutlet weak var headshotImage: UIImageView!
    @IBOutlet weak var headshotHeight: NSLayoutConstraint!
    @IBOutlet weak var headshotWidth: NSLayoutConstraint!
    @IBOutlet weak var nameAndSummaryHeight: NSLayoutConstraint!
    @IBOutlet var feedbackImages: [UIImageView]!
    
    //MARK: - Set Summary Variable Outlets
    @IBOutlet weak var setExerciseLabel: UILabel!
    @IBOutlet weak var setLoadLabel: UILabel!
    @IBOutlet weak var setVelocityTargetLabel: UILabel!
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var setRepsCompletedLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    
    
    // DEBUG Variables
    var reps: [Int] = [0, 1, 2, 3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if reps.count == 0 {
            navigationController?.popViewController(animated: true)
            
//      To be uncommented after full nav controller is restored
//        if completedReps.count == 0 {
//            navigationController?.popViewController(animated: true)
//
        } else {
            adjustLayout()
            layoutScrollView()
            updateSetData()
        }
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let currentPage = sender.currentPage
        scrollView.setContentOffset(CGPoint(x: CGFloat(currentPage) * view.frame.width, y: 0), animated: true)
    }
    
    func createSlides() -> [RepSummarySlide] {
        for index in 0 ..< completedReps.count {
            let slide = Bundle.main.loadNibNamed("RepSummarySlide", owner: self, options: nil)?.first as! RepSummarySlide
            slide.repLabel.text = "Rep: \(index + 1)"
            
            let feedbackIndex = completedReps[index].averageFeedbackImageIndex
            slide.feedbackImage.image = imageArray[feedbackIndex]
            feedbackImages[index].image = imageArray[feedbackIndex]
            
            slides.append(slide)
        }
        return slides
    }
    
    func setUpScrollView(slides: [RepSummarySlide]) {
        scrollView.frame = CGRect(x: 0, y: scrollView.frame.minY, width: view.frame.width, height: scrollView.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    func adjustLayout() {
        headshotHeight.constant = view.bounds.height / 5.5
        headshotWidth.constant = view.bounds.height / 5.5
        nameAndSummaryHeight.constant = headshotWidth.constant / 6
        
        headshotImage.asCircle()
        
        for image in feedbackImages {
            image.asCircle()
        }
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
        setVelocityTargetLabel.text = "\(currentWorkout.targetVelocity) m/s"
        setNumberLabel.text = String(currentWorkout.setNumber)
        setRepsCompletedLabel.text = String(currentWorkout.targetReps)
        firstNameLabel.text = currentWorkout.athleteFirst
        lastNameLabel.text = currentWorkout.athleteLast
    }
    
}

extension WorkoutSummaryViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(floorf(Float(scrollView.contentOffset.x) / Float(scrollView.frame.width)))
    }
}
