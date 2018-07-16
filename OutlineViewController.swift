//
//  OutlineViewController.swift
//  LazyMode
//
//  Created by Work on 4/12/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit
import CoreData
import Foundation

// View Contorller for Outline View
class OutlineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var lazyBrain = LazyBrain()
    var actions :[Action] = [Action]()
    var dataManager = DataManager()
    var estimations = [Int?]() {
        didSet {
            overDueDisplay.number = overDueNum
            conflictDisplay.number = conflictNum
            startNowDisplay.number = startNowNum
            changeOverallFreeTime()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    
    // This function is called before view will appear on the screen.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        actions = dataManager.fecthRepetitionActionList()
        estimations = lazyBrain.getEstimation()
        selectedIndexPath = nil
        //reloadDashBoard()
        tableView.reloadData()
        
    }
    

    
    // MARK: - Dashboard
    
    //overdue
    var overDueNum : Int {
        var total = 0
        for action in actions {
            if action.isOverdue() {
                total += 1
            }
        }
        return total
    }
    
    @IBOutlet weak var overDueDisplay: StatusBlockView!
    
    //conflict - too late to start
    var conflictNum: Int {
        var total = 0
        for estimation in estimations {
            if lazyBrain.isConflict(estimation) {
                total += 1
            }
        }
        return total
    }
    @IBOutlet weak var conflictDisplay: StatusBlockView!
    
    //start now - you are supposed to start the task now
    var startNowNum: Int {
        var total = 0
        for estimation in estimations {
            if lazyBrain.isToStart(estimation) {
                total += 1
            }
        }
        return total
    }
    @IBOutlet weak var startNowDisplay: StatusBlockView!
    
    // free time - display the free time of the action 
    
    // computed property : calculated the overall free time 
    // which is currently minimun free time of all acitons 
    // the minimun value can be 0
    var overallFreeTime: Int {
        var min = Int.max
        for estimation in estimations {
            if let value = estimation {
                if value < min{
                    min = value
                }
            } else {
                min = 0
            }
        }
        return min
    }
    
    // constants of Int representing Duration in minuites
    fileprivate struct Duration{
        static let Hour = 60
        static let Day = 24 * Hour
        static let Week = 7 * Day
    }
    
    // This function changes the display of the Free Time StatusBlock 
    // according to the overall free time.
    func changeOverallFreeTime(){
        var number :Int = 0
        if overallFreeTime > 10 *  Duration.Week {
            number = overallFreeTime
            freeTimeDisplay.unit = "Infinite"
        } else if (overallFreeTime < 0){
            number = 0
            freeTimeDisplay.unit = "Minutes"
        } else if overallFreeTime < Duration.Hour{
            number = overallFreeTime
            freeTimeDisplay.unit = "Minutes"
        } else if overallFreeTime < 100 * Duration.Hour {
            number = overallFreeTime / Duration.Hour
            freeTimeDisplay.unit = "Hours"
        } else {
            number = overallFreeTime / Duration.Day
            freeTimeDisplay.unit = "Days"
        }
        freeTimeDisplay.number = number
    }
    @IBOutlet weak var freeTimeDisplay: StatusBlockView!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // Table view data source function
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    // MARK: - Table View Cell Display
    
    var selectedIndexPath: IndexPath?
    
    // Table view data source function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return overDueNum
        case 1:
            return numberOfRowsInSection(1, from: 0)
        case 2:
            return numberOfRowsInSection(7, from: 1)
        case 3:
            return numberOfRowsInSection(7 * 2, from: 7)
        case 4:
            return numberOfRowsInSection(Setting.MaxPredictingDays, from: 2 * 7)
        default:
            return 0
        }

    }
    
    func numberOfRowsInSection(_ days: Int, from startDay: Int) -> Int {
        var result = 0
        for action in actions {
            if action.isDueWithIn(days, from: startDay){
                result += 1;
            }
        }
        return result
    }
    
    func indexTransform(_ section: Int, row: Int)->Int{
        switch section {
        case 0:
            return row
        case 1:
            return overDueNum + row
        case 2:
            return overDueNum + numberOfRowsInSection(1, from: 0) + row
        case 3:
            return overDueNum + numberOfRowsInSection(7, from: 0) + row
        case 4:
            return overDueNum + numberOfRowsInSection(7 * 2, from: 0) + row
        default:
            return 0
        }
    }
    
    
    var didConfirm: Bool = false
    // Table view data source function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexTransform(indexPath.section, row: indexPath.row)
        let action = actions[index]
        let estimation = estimations[index]
        if selectedIndexPath != nil && (indexPath as NSIndexPath).compare(selectedIndexPath!) == ComparisonResult.orderedSame  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath) as! DetailViewCell
            cell.action = action
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.imageView?.image = nil
            cell.textLabel?.text = action.value(forKey: "name") as? String
            
            if action.conflictResolvingRule == Rule.Drop {
                cell.detailTextLabel?.text = "Dropped"
            } else if action.conflictResolvingRule == Rule.Force{
                cell.detailTextLabel?.text = "Force"
            } else if action.conflictResolvingRule == Rule.Cut {
                cell.detailTextLabel?.text = "Cut"
            } else if action.conflictResolvingRule == Rule.Ignore {
                cell.detailTextLabel?.text = "Ignore"
            } else if (action.isOverdue()){
                cell.detailTextLabel?.text = "Overdue"
                cell.imageView?.image = UIImage(named: "RedVertical")
            } else if lazyBrain.isConflict(estimation){
                cell.detailTextLabel?.text = "\(estimation! / Duration.Hour) Hours -_-# "
                cell.imageView?.image = UIImage(named: "OrangeVertical")
            } else if lazyBrain.isToStart(estimation){
                cell.detailTextLabel?.text = "Start Now!"
                cell.imageView?.image = UIImage(named: "YellowVertical")
            } else {
                cell.detailTextLabel?.text = "\(estimation! / (60 * 24)) days \(estimation! % (60 * 24) / 60) hours \(estimation! % 60) minutes"
            }
            
            if action.virtual || action.conflictResolvingRule == Rule.Drop {
                cell.textLabel?.textColor = UIColor.lightGray
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            
            if action.virtual && action.hidden {
                cell.isHidden = true
            } else {
                cell.isHidden = false
            }
            
            return cell
        }
        
    }
    
    // Table view data source function
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if didConfirm {
            didConfirm = false
            return
        }
        let index = indexTransform(indexPath.section, row: indexPath.row)
        let action = actions[index]
        if action.virtual {
            return
        }
        
        if selectedIndexPath == nil {
            selectedIndexPath = indexPath
            tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        } else if (indexPath as NSIndexPath).compare(selectedIndexPath!) == ComparisonResult.orderedSame {
            return
        } else {
            let previousSelectedIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            tableView.reloadRows(at: [previousSelectedIndexPath!, selectedIndexPath!], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = indexTransform(indexPath.section, row: indexPath.row)
        let action = actions[index]
        if action.virtual && action.hidden {
            return 0
        }
        if selectedIndexPath != nil && (indexPath as NSIndexPath).compare(selectedIndexPath!) == ComparisonResult.orderedSame  {
            return 130
        }
        return 44
    }
    
    // MARK: - Detail Cell Button Actions
    @IBAction func complete(_ sender: UIButton) {
        if let detailView = sender.superview?.superview as? DetailViewCell{
            detailView.slider.value = 100
        }
        detailConfirm(sender)
    }
    @IBAction func confirm(_ sender: UIButton) {
        detailConfirm(sender)
    }
    
    // This function will update both Model and View when a given button is pressed.
    // More precisely, it will save all the changes made, and update the UI
    func detailConfirm(_ sender: UIButton){
        if let detailView = sender.superview?.superview as? DetailViewCell{
            if let action = detailView.action{
                if let prevIndexPath = selectedIndexPath{
                    selectedIndexPath = nil
                    tableView.reloadRows(at: [prevIndexPath], with: UITableViewRowAnimation.automatic)
                }
                
                action.completionRate = detailView.slider.value
                do {
                    try action.managedObjectContext?.save()
                } catch {
                    let saveError = error as NSError
                    print(saveError)
                }
                updateUI()
            }
        }
    }
    
    // update the UI to display correct info.
    func updateUI(){
        actions = dataManager.fecthRepetitionActionList()
        estimations = lazyBrain.getEstimation()
        tableView.reloadData()
    }
    
    // This function decides the title for header in each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && overDueNum > 0 {
            return "Overdue"
        } else if section == 1 && numberOfRowsInSection(1, from: 0) > 0 {
            return "Due in 1 Day"
        } else if section == 2 && numberOfRowsInSection(7, from: 1) > 0 {
            return "Due in 1 Week"
        }else if section == 3 && numberOfRowsInSection(7 * 2, from: 7) > 0 {
            return  "Due in 2 Weeks"
        }
        else if section == 4 && numberOfRowsInSection(Setting.MaxPredictingDays, from: 7 * 2) > 0 {
            return "Later"
        }else {
            return nil
        }
    }
}
