//
//  ConflictViewController.swift
//  LazyMode
//
//
//  Created by Work on 4/20/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

//  View controller for conflict view.
class ConflictViewController: UIViewController {
    
    var lazyBrain = LazyBrain()
    var actions :[Action] = [Action]()
    var dataManager = DataManager()
    var estimations = [Int?]()
    var currentAction:Action?
    
    @IBOutlet weak var numDisplay: UILabel!
    @IBOutlet weak var pickerView: UIView!
    @IBOutlet weak var titleDisplay: UILabel!
    
    @IBOutlet weak var descriptionDisplay: UILabel!
    // This function updates the UI for conflict view, including trying to find a new conflict action, 
    // and displays its info. appropriately.
    func updateUI(){
        actions = dataManager.fecthRepetitionActionList()
        estimations = lazyBrain.getEstimation()
        var count = 0
        for (i, action) in actions.enumerated() {
            print(action.name)
            print(estimations[i])
            if lazyBrain.isConflict(estimations[i]){
                count += 1;
            }
        }
        
        numDisplay.text = String(count)
        if count > 0 {
            pickerView.isHidden = false
            for (i, action) in actions.enumerated() {
                if lazyBrain.isConflict(estimations[i]){
                    currentAction = action
                    break
                }
            }
            
        } else {
            pickerView.isHidden = true
            currentAction = nil
            titleDisplay.text = ""
        }
        
        if let displayAction = currentAction {
            print("The rule is \(displayAction.conflictResolvingRule)")
            titleDisplay.text = displayAction.name
            type = displayAction.conflictResolvingRule
            print("The type is \(type)")
            print("The seg is \(typePicker.selectedSegmentIndex)")
            print()
            updateSelectUI(typePicker)
        }
    }
    
    // This function will be called before the view appear on the screen, the UI will be updated
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }

    // MARK: - Outlets
    var type: Int {
        get {
            return typePicker.selectedSegmentIndex + 1
        }
        set {
            if type  > 0 {
                typePicker.selectedSegmentIndex = newValue - 1
            } else {
                typePicker.selectedSegmentIndex = 3
            }
        }
    }
    
    @IBOutlet weak var descriptionImage: UIImageView!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var typePicker: UISegmentedControl!
    @IBAction func typeChanged(_ sender: UISegmentedControl) {
        sender.reloadInputViews()
        updateSelectUI(sender)
    }
    
    // This function will be called when "confirm" button is called
    // It will save all the changes made, and updateUI for conflict view
    @IBAction func confirm(_ sender: UIButton) {
        currentAction?.conflictResolvingRule = type
        if let action = currentAction {
            if action.virtual {
                let rules = dataManager.loadConflictRulesByDueDate()
                dataManager.refreshRules(actions, rules: rules)
            } else {
               action.saveContext()
            }
            updateUI()
        }
    }
    
    // This function updates the UI for the select view embeded in conflict view
    func updateSelectUI(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            descriptionTitle.text = "Cut"
            descriptionImage.image = UIImage(named: "Cut")
            descriptionDisplay.text = "Cut - Stop doing the action at the due date. That is, do as much as possible. "
        case 1:
            descriptionTitle.text = "Force"
            descriptionImage.image = UIImage(named: "Force")
            descriptionDisplay.text = "Force - Try to finish the task before due date. Ignore other tasks if neccessary."
        case 2:
            descriptionTitle.text = "Drop"
            descriptionImage.image = UIImage(named: "Drop")
            descriptionDisplay.text = "Drop - Don't do this task. Just drop it."
        case 3:
            descriptionTitle.text = "Ignore"
            descriptionImage.image = UIImage(named: "Ignore")
            descriptionDisplay.text = "Finish it, even after the due date. Good Student..."
        default:
            descriptionDisplay.text = ""
            break
        }
    }
    
    // This function prepares for the segues.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}
