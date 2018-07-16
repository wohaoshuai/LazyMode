//
//  HabitViewController.swift
//  LazyMode
//
//  Created by Tony on 4/29/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

// Habit View Controller
class HabitViewController: UIViewController, UITextFieldDelegate {
    var habit: Habit?
    var dataManager = DataManager()
    @IBOutlet weak var actionTitle: UITextField! { didSet { actionTitle.delegate = self}}
    @IBOutlet weak var timePicker: UISegmentedControl!
    @IBOutlet weak var durationPicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Do any additional setup after loading the view.
    }
    
    // This function load the data
    func loadData(){
        if let habit = habit {
            actionTitle.text = habit.name
            timePicker.selectedSegmentIndex = habit.type
            durationPicker.countDownDuration = habit.duration
            //durationPicker.reloadInputViews()
        }
    }

    // This funciton is called when the "cancel" button is clicked
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // This funciton is called when the "save" button is clicked, any changes being made should be saved to Core Data
    @IBAction func save(_ sender: UIButton) {
        if habit == nil{
            habit = dataManager.createObject("Habit") as? Habit
        }
        habit!.name = actionTitle.text ?? "Untitiled Habit"
        habit!.duration  = durationPicker.countDownDuration //duration in NSDuration
        if timePicker.selectedSegmentIndex == -1 {
            habit!.type = 0
        } else {
            habit!.type = timePicker.selectedSegmentIndex
        }
        habit!.saveContext()
        self.dismiss(animated: true, completion: nil)
    }
    
    // This function hides the button whenever user touches "Return" button on the keyboard.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
        // called when 'return' key pressed. return false to ignore.
    {
        textField.resignFirstResponder()
        return true
    }

}
