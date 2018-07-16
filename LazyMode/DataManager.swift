//
//  dataManager.swift
//  LazyMode
//
//  Created by Work on 4/13/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import Foundation
import CoreData
import UIKit
public struct Setting {
    static let MaxPredictingDays = 24
    static let MaxPredictingDuration = 60 * 24 * MaxPredictingDays // In minutes
}

//This funciton helps to fetch certain data in Core Data
class DataManager {

    
    var actions :[Action] = [Action]()
    
    // This function fetch and return an array of Action with given property
    // 1.Ordered by due date in ascending order
    // 2.Filter out all completed actions
    // 3.Create repetion actions
    func fecthRepetitionActionList()->[Action]{
        loadDataByDueDate()
        repetitionCreator()
        filterCompletion()
        copyConflictRules(actions) //#new week4
        return filterMaxPredictingDays(actions)
    }
    
    // This funciton loads all actions from the Core Data database by Due Date
    func loadDataByDueDate(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Action")
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let result = try managedContext.fetch(fetchRequest)
            actions = result as! [Action]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    // This funciton loads all actions from the Core Data database
    func loadDataByReviewDate()->[Action]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let sortDescriptor = NSSortDescriptor(key: "reviewDate", ascending: true)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Action")
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let result = try managedContext.fetch(fetchRequest)
            actions = result as! [Action]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return actions
    }
    
    // This function creates virtual actions for repeated actions. For example, if one task is repeating every day.
    // Then, this function will create new actions from the first available date to the threshold date
    func repetitionCreator(){
        for action in actions {
            if action.isRepeat(){
                var firstDueDate = action.dueDate
                let currentDate = Date()
                if action.isOverdue(){
                    let repeatitionDuration:Int = 60 * 60 * 24 * action.repetitionDays
                    let skipNumber = 1 + Int(Double(currentDate.minutesFrom(action.dueDate) * 60)) / repeatitionDuration
                    firstDueDate = action.dueDate + Double((repeatitionDuration / 60) * skipNumber) * 60
                }
                
                let estimationMaxDays = 20 // set this to change how many days the system can predict
                let endDate = Date() + Double(60 * 24 * estimationMaxDays) * 60
                while firstDueDate < endDate {
                    if firstDueDate != action.dueDate {
                        let newAciton = action.copy() as! Action
                        newAciton.dueDate = firstDueDate
                        actions.append(newAciton)
                    }
                    let repeatitionDuration:Int = 60 * 60 * 24 * action.repetitionDays
                    firstDueDate = firstDueDate + Double((repeatitionDuration / 60)) * 60
                }
            }
        }
        actions.sort{$0.dueDate < $1.dueDate}
    }
    
    // This function will remove all completed action from the given action list
    func filterCompletion(){
        for (i, action) in actions.enumerated().reversed(){
            if action.completionRate == 100 {
                actions.remove(at: i)
            }
        }
    }
    
    // Repetition Hide filter.
    // Returns an array filtering out all repetition hide actions. 
    func filterRepetitionHide(_ actions: [Action])->[Action]{
        var result = [Action]()
        for action in actions {
            if !action.hidden {
                result.append(action)
            }
        }
        return result
    }
    
    // Filter actions by "system max prediction days"
    func filterMaxPredictingDays(_ actions: [Action])->[Action]{
        var result = [Action]()
        let maxDate = Date() + Double(Setting.MaxPredictingDuration) * 60
        for action in actions {
            if action.dueDate < maxDate {
                result.append(action)
            }
        }
        return result
    }
    
    //This function will add correpsonding resolving (if any) rule to each virtual action in the action list
    //If there is no rule, nothing will be added then
    func copyConflictRules(_ actions: [Action]){
        let rules = loadConflictRulesByDueDate()
        for rule in rules {
            for action in actions {
                if action.virtual && rule.uuid == action.uuid && rule.dueDate == action.dueDate{
                    action.conflictResolvingRule = rule.conflictResolvingRule
                }
            }
        }
    }
    
    //This function will initialize the rules by fetching all rules from Core Data.
    func loadConflictRulesByDueDate()->[ConflictResolving]{
        var rules = [ConflictResolving]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let sortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ConflictResolving")
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let result = try managedContext.fetch(fetchRequest)
            rules = result as! [ConflictResolving]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return rules
    }
    // MARK: - Week 4
    
    //This function will check if the action already has a conflict resolving rule in rule list
    // Returns the rule, if there is one, otherwise return nil
    func getRuleByAction(_ action: Action)->ConflictResolving?{
        let rules = loadConflictRulesByDueDate()
        for rule in rules {
            if action.virtual && rule.uuid == action.uuid && rule.dueDate == action.dueDate{
                return rule
            }
        }
        return nil
    }
    
    //This function refresh the rules list using the information from action list
    // All current rules will be deleted, then the rules will be rebuilt by current
    // virutal actions in the action list.
    func refreshRules(_ actions: [Action], rules: [ConflictResolving]){
       //first, delete all exsisting rules
        for rule in rules {
           deleteObject(rule)
        }
        //second, add new rules based on actions
        for action in actions {
            if action.virtual && action.conflictResolvingRule != 0 {
                let rule = createObject("ConflictResolving") as! ConflictResolving
                rule.conflictResolvingRule = action.conflictResolvingRule
                rule.dueDate = action.dueDate
                rule.uuid = action.uuid
            }
        }
    }
    
    //Helper function to delete any NSManagedObject
    func deleteObject(_ obj: NSManagedObject){
        obj.managedObjectContext?.delete(obj)
        do {
            try obj.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
    
    //Helper funciton to create NSManagedObject
    func createObject(_ type: String)->NSManagedObject{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: type,in: managedContext)!
        return NSManagedObject(entity: entityDescription, insertInto: managedContext)
    }
    
    // Saves the state
    func saveContext(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        do {
            try managedContext.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
    
    // Load Data of Type
    func loadData(_ type: String)->[NSManagedObject]{
        var results = [NSManagedObject]()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: type)
        do {
            let result = try managedContext.fetch(fetchRequest)
            results = result as! [NSManagedObject]
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return results
    }

}
