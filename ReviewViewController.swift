//
//  ReviewViewController.swift
//  LazyMode
//
//  Created by Work on 4/20/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit


// Reivew View Controller
class ReviewViewController: UIViewController {
    
    var smvc: DetailViewController!
    var reviews = [Action]()
    @IBOutlet weak var remainingDisplay: UILabel!
    @IBOutlet weak var titleDisplay: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // This function will be invoked by complete button to set taks complete, and save all changes update UI
    @IBAction func complete(_ sender: UIButton) {
        if reviews.count > 0 {
            smvc.completionValue = 100
            moveToNextReview()
        }
    }
    
    // This function will be invoked by check button to save all changes and update UI
    @IBAction func check(_ sender: UIButton) {
        if reviews.count > 0 {
            moveToNextReview()
        }
    }
    
    // This helper function move the view to display next review (UI Related Function)
    fileprivate func moveToNextReview(){
        let review = reviews[0]
        review.reviewDate = Date()
        review.completionRate = smvc.completionValue
        review.durationDays = smvc.durationDays
        review.durationMinutes = smvc.durationMinutes
        review.saveContext()
        reviews.remove(at: 0)
        updateUI()
    }
    
    // This funciton will be called before view appear to set up UI correctly
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let dataManager = DataManager()
        dataManager.loadDataByReviewDate()
        dataManager.filterCompletion()
        reviews = dataManager.actions
        filterReviews()
        updateUI()
    }

    // This function updates the UI to display correct information
    fileprivate func updateUI(){
        remainingDisplay.text = String(reviews.count)
        if reviews.count == 0 {
            titleDisplay.text = ""
            smvc.action = nil
        } else {
            titleDisplay.text = reviews[0].name
            smvc.action = reviews[0]
        }
    }
    
    // This function set "reviews" in the controller to be a set of reviews that indeed needs to be reviewd
    // The filter is defines in Action.shouldBeReview() function
    fileprivate func filterReviews(){
        var results = [Action]()
        for review in reviews {
            if review.shouldBeReview() {
                results.append(review)
            }
        }
        reviews = results
    }

    // MARK: - Navigation
    // Prepare embeded segue to detail view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            smvc = segue.destination as! DetailViewController
        }
    }


}
