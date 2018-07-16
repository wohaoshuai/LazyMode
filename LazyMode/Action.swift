//
//  Action.swift
//  LazyMode
//
//  Created by Work on 4/13/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit
import CoreData

// This object representing a Action in Core Data
class Action: NSManagedObject, NSCopying{
    
    
    @NSManaged var accuracy: Int
    @NSManaged var completionRate: Float
    @NSManaged var dueDate: Date
    @NSManaged var durationDays: Int
    @NSManaged var durationMinutes: Int
    @NSManaged var importance: Int
    @NSManaged var name: String
    @NSManaged var repetitionDays: Int
    @NSManaged var type: Int
    @NSManaged var hidden: Bool
    @NSManaged var reviewDate: Date?
    @NSManaged var reviewFrequency: Int
    @NSManaged var virtual: Bool
    @NSManaged var conflictResolvingRule: Int
    @NSManaged var uuid: String!
    
    // representing the next date when the action should be reviewed.
    var nextReviewDate: Date{
        var reviewRatio : Double = 1
        switch importance {
        case 0:
            reviewRatio = 0.5
        case 1:
            reviewRatio = 1
        case 2:
            reviewRatio = 2
        default:
            break
        }
        let interval = Int(Double(reviewFrequency) * reviewRatio)
        return reviewDate! + TimeInterval(interval)
    }
    
    // init
    init(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Action", in: managedContext)!
        super.init(entity: entityDescription, insertInto: nil)
        reviewDate = Date()
    }
    
    init(intervalFromNow: TimeInterval, completionRate: Float, durationDays: Int, durationMinutes: Int){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "Action", in: managedContext)!
        super.init(entity: entityDescription, insertInto: nil)
        self.dueDate = Date(timeInterval: intervalFromNow, since: Date())
        self.completionRate = completionRate
        self.durationDays = durationDays
        self.durationMinutes = durationMinutes
        reviewDate = Date()
    }

    
    // init from view
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: context)
        if reviewDate == nil {
            reviewDate = Date() - Double(reviewFrequency) * 1 // To be changed
            saveContext()
        }
        if uuid == nil {
            uuid = UUID().uuidString
        }
    }
    
    //This function check if the action is overdue (due date is earlier than current date)
    func isOverdue()->Bool{
        let currentDate = Date()
        return dueDate < currentDate
    }
    
    //This function checks if the action is repeating
    func isRepeat()->Bool{
        if repetitionDays == 0 {
            return false
        } else {
            return true
        }
    }
    
    // This fucntion check if the aciton is completed
    // Return true if so, false otherwise
    func isCompleted()->Bool{
        if completionRate == 100 {
            return true
        } else {
            return false
        }
    }
    
    // Called when any value of action is changed. 
    // Update the completion rate when the completionRate is changed.
    override func didChangeValue(forKey key: String) {
        super.didChangeValue(forKey: key)
        switch key {
        case "completionRate":
            if completionRate == 100 && !virtual && isRepeat(){
                if isOverdue(){
                    moveDueDateToNextAvailableDate()
                } else {
                    moveToNextDueDate()
                }
                completionRate = 0
            }
        default:
            break
        }
    }
    
    //This private function should be called when a task is completed
    //It will handle new due date for completed repeating action
    fileprivate func moveDueDateToNextAvailableDate(){
        var firstDueDate = dueDate
        let currentDate = Date()
        if self.isOverdue(){
            let repeatitionDuration:Int = 60 * 60 * 24 * self.repetitionDays
            let skipNumber = 1 + Int(Double(currentDate.minutesFrom(self.dueDate) * 60)) / repeatitionDuration
            firstDueDate = self.dueDate + Double((repeatitionDuration / 60) * skipNumber) * 60
        }
        
        dueDate = firstDueDate
    }
    
    // This function simply move the due date to the next due date by adding one 
    // repeatition duration.
    fileprivate func moveToNextDueDate(){
        let repeatitionDuration:Int = 60 * 24 * self.repetitionDays
        dueDate = dueDate + TimeInterval(repeatitionDuration)
    }
    
    // This function enable action.copy() fucntion to Deep Copy itself
    // Returns a AnyObject (Action) which having the same atrributes as itself
    // Except the completionRate is set to 0
    // Also the repetitionDays is set to 0
    func copy(with zone: NSZone?) -> Any {
        let newAction = Action()
        newAction.accuracy = self.accuracy
        newAction.completionRate = 0
        newAction.dueDate = self.dueDate
        newAction.durationDays = self.durationDays
        newAction.durationMinutes = self.durationMinutes
        newAction.importance = self.importance
        newAction.name = self.name
        newAction.repetitionDays = 0
        newAction.type = self.type
        newAction.virtual = true
        newAction.hidden = self.hidden
        newAction.reviewDate = self.reviewDate
        newAction.reviewFrequency = self.reviewFrequency
        newAction.uuid = self.uuid
        newAction.conflictResolvingRule = 0
        return newAction
    }
    
    //This function decides if the action should be reviewed now
    func shouldBeReview()->Bool{
        if completionRate < 100 && !virtual &&  nextReviewDate < Date(){
            return true
        } else {
            return false
        }
    }
    
    //This function decides if the action has conflict
    
    // Saves the state
    func saveContext(){
        do {
            try self.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
    
    // MARK: - Week 4
    //This function decides if the action is due within a given duration in days, and an integer representing the start days from current day.
    func isDueWithIn(_ days: Int, from startDays: Int)->Bool{
        let currentDate = Date()
        let duration =  Double(dueDate.minutesFrom(currentDate) * 60)
        let durationInDay = Int(duration / DurationInSeconds.Day)
        if durationInDay >= startDays && durationInDay < days {
            return true
        } else {
            return false
        }
    }
}
