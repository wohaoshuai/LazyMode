//
//  ConflictRuleViewController.swift
//  LazyMode
//
//  Created by Tony on 4/28/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit

//Controller of Conflict Rule View
class ConflictRuleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var lazyBrain = LazyBrain()
    var actions = [Action]()
    var actionsWithRule = [Action]()
    var actionsWithConflict = [Action]()
    var dataManager = DataManager()
    var selectedIndexPath :IndexPath?
    var didConfirm: Bool = false
    @IBOutlet weak var descriptionImage: UIImageView!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var welcomeTitle: UILabel!
    
    // Tis function is called when the view will appear, the data will be reloaded.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        updateUI()
    }
    
    // This function updates the UI
    func updateUI(){
        actions = dataManager.fecthRepetitionActionList()
        actionsWithRule = lazyBrain.actionsWithRule(actions)
        actionsWithConflict = lazyBrain.actionWithConflict(actions)
        selectedIndexPath = nil
        descriptionImage.isHidden = true
        descriptionTitle.isHidden = true
        welcomeTitle.isHidden = false
        tableView.reloadData()
    }

    // This function is called when the "back" buttong is clicked
    // Return to the previous view.
    @IBAction func Back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // TableView data source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return actionsWithRule.count
        default:
            return actionsWithConflict.count //be careful here.
        }
    }
    
    // TableView data source
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if didConfirm {
            didConfirm = false
            return
        }
        
        if selectedIndexPath == nil {
            selectedIndexPath = indexPath
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        } else {
            let previousSelectedIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            tableView.reloadRows(at: [previousSelectedIndexPath!, selectedIndexPath!], with: UITableViewRowAnimation.automatic)
        }
        descriptionImage.isHidden = false
        descriptionTitle.isHidden = false
        welcomeTitle.isHidden = true

    }
    
    // TableView data source - height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedIndexPath != nil && (indexPath as NSIndexPath).compare(selectedIndexPath!) == ComparisonResult.orderedSame  {
            return 130
        }
        return 44
    }
    
    // Table view data source function - cell display
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let action = findActionByPath(indexPath)
        
        if selectedIndexPath != nil && (indexPath as NSIndexPath).compare(selectedIndexPath!) == ComparisonResult.orderedSame  {
            print("show rule")
            let cell = tableView.dequeueReusableCell(withIdentifier: "rule", for: indexPath) as! RuleViewCell
            if action.conflictResolvingRule == 0 {
                cell.typePicker.isSelected = false
            } else {
                cell.typePicker.selectedSegmentIndex = action.conflictResolvingRule - 1
            }
            
            cell.action = action
            cell.actionTitle.text = action.name
            updateSelectUI(cell.typePicker)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = action.name
            
            if action.conflictResolvingRule == Rule.Drop {
                cell.detailTextLabel?.text = "Dropped"
            } else if action.conflictResolvingRule == Rule.Force{
                cell.detailTextLabel?.text = "Force"
            } else if action.conflictResolvingRule == Rule.Cut {
                cell.detailTextLabel?.text = "Cut"
            } else if action.conflictResolvingRule == Rule.Ignore {
                cell.detailTextLabel?.text = "Ignore"
            } else {
                cell.detailTextLabel?.text = nil
            }
            
            if action.virtual || action.conflictResolvingRule == Rule.Drop {
                cell.textLabel?.textColor = UIColor.lightGray
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            
            
            return cell
        }
        
    }
    
    // This function update the UI when the type picker changes its value.
    @IBAction func pickerChanged(_ sender: UISegmentedControl) {
        updateSelectUI(sender)
    }
    
    // Save and updateUI when the "reset" button is clicked
    @IBAction func reset(_ sender: UIButton) {
        if let ruleCell = sender.superview?.superview as? RuleViewCell{
            ruleCell.typePicker.selectedSegmentIndex = -1
        }
        ruleConfirm(sender)
    }
    
    // Save and updateUI when the "confirm" buttong is clicked
    @IBAction func confirm(_ sender: UIButton) {
        ruleConfirm(sender)
    }
    
    // Helper funciton to save the rule and update the UI
    fileprivate func ruleConfirm(_ sender: UIButton){
        if let ruleCell = sender.superview?.superview as? RuleViewCell{
            if let action = ruleCell.action{
                if let preIndexPath = selectedIndexPath{
                    selectedIndexPath = nil
                    tableView.reloadRows(at: [preIndexPath], with: UITableViewRowAnimation.automatic)
                }
                

                action.conflictResolvingRule = ruleCell.typePicker.selectedSegmentIndex + 1
                
                if action.virtual {
                    let rules = dataManager.loadConflictRulesByDueDate()
                    dataManager.refreshRules(actions, rules: rules)
                } else {
                    action.saveContext()
                }
                
                updateUI()
            }
        }
    }
    
    // This function updates the UI for the select view embeded in conflict view
    func updateSelectUI(_ sender: UISegmentedControl){
        switch sender.selectedSegmentIndex {
        case 0:
            descriptionTitle.text = "Cut"
            descriptionImage.image = UIImage(named: "Cut")
        case 1:
            descriptionTitle.text = "Force"
            descriptionImage.image = UIImage(named: "Force")
        case 2:
            descriptionTitle.text = "Drop"
            descriptionImage.image = UIImage(named: "Drop")
        case 3:
            descriptionTitle.text = "Ignore"
            descriptionImage.image = UIImage(named: "Ignore")
        default:
            break
        }
    }
    
    // This funciton returns a action of given NSIndexPath
    func findActionByPath(_ indexPath: IndexPath)->Action{
        let row = indexPath.row
        let section = indexPath.section
        var action :Action!
        switch section {
        case 0:
            action = actionsWithRule[row]
            print("section 0 row \(row)")
        case 1:
            action = actionsWithConflict[row]
            print("section 1 row \(row)")
        default:
            break
        }
        return action
    }

    // This funciton set the title for all header of each section in the table view
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && actionsWithRule.count > 0 {
            return "Solved Actions"
        } else if section == 1 && actionsWithConflict.count > 0 {
            return "Conflicting Actions"
        } else {
            return nil
        }
    }

}
