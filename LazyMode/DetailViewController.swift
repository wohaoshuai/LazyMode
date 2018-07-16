//
//  detailViewController.swift
//  LazyMode
//
//
//  Created by Work on 4/20/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

//  Detail View Controller embeded in the Reivew View
class DetailViewController: UITableViewController {
    var action: Action? {
        didSet{
            if let review = action {
                view.isHidden = false
                completionValue = review.completionRate
                durationMinutes = review.durationMinutes
                durationDays = review.durationDays
            } else {
                view.isHidden = true
            }
        }
    }
    
    // completion value
    var completionValue:Float = 0 {
        didSet {
            if (completionValue == 100){
                completionDisplay.text = "Compeleted"
            } else {
                completionDisplay.text =  String(Int(completionValue)) + " %"
            }
            completionPicker.value = completionValue
            completionPicker.reloadInputViews()
        }
    }
    @IBOutlet weak var completionDisplay: UILabel!
    @IBOutlet weak var completionPicker: UISlider!
    @IBAction func completionPcikerChanged(_ sender: UISlider) {
        completionValue = completionPicker.value
    }
    
    // duration Value
    var durationMinutes:Int = 0
        {
        didSet {
            updateDurationUI()
        }
    }
    var durationDays:Int = 0 {
        didSet {
            updateDurationUI()
        }
    }
    
    // This function updates UI for displaying duration values
    func updateDurationUI(){
        durationMinuteDisplay.text = String(durationDays) + " Days"
        durationDisplay.text = "Duration \(durationDays) Days \(durationMinutes / 60) Hours"
        durationDayPicker.value = Double(durationDays)
        durationMinutePicker.countDownDuration = Double(durationMinutes) * 60.0
        durationMinutePicker.reloadInputViews()
    }
    
    @IBOutlet weak var durationDayPicker: UIStepper!
    @IBOutlet weak var durationDisplay: UILabel!
    @IBOutlet weak var durationMinuteDisplay: UILabel!
    
    @IBOutlet weak var durationMinutePicker: UIDatePicker!
    @IBAction func durationMinutePickerChanged(_ sender: UIDatePicker) {
        durationMinutes = Int(sender.countDownDuration) / 60
    }
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        durationDays = Int(sender.value)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

}
