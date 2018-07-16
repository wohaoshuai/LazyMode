//
//  LazyBrain.swift
//  LazyMode
//  This class is the core model of evaluating the status of each actions
//  and gives useful information for user to make smarter schedule. (and to be lazy)
//
//  Created by Work on 4/11/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import UIKit
import Foundation
import CoreData
//// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
//// Consider refactoring the code to use the non-optional operators.
//fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l < r
//  case (nil, _?):
//    return true
//  default:
//    return false
//  }
//}
//
//// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
//// Consider refactoring the code to use the non-optional operators.
//fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
//  switch (lhs, rhs) {
//  case let (l?, r?):
//    return l <= r
//  default:
//    return !(rhs < lhs)
//  }
//}
//
//
////http://stackoverflow.com/questions/26198526/nsdate-comparison-using-swift
////overwrite operators for easier manipulation on NSDate object
//
//public func ==(lhs: Date, rhs: Date) -> Bool {
//    return lhs === rhs || lhs.compare(rhs) == .orderedSame
//}

//public func <(lhs: Date, rhs: Date) -> Bool {
//    return lhs.compare(rhs) == .orderedAscending
//}
//
//public func +(lhs: Date, minute: Int) -> Date {
//    let seconds: TimeInterval = Double(minute) * 60
//    return lhs.addingTimeInterval(seconds)
//}

//public func +(lhs: Date, duration: TimeInterval) -> Date {
//    return lhs.addingTimeInterval(duration)
//}

//public func -(lhs: Date, minute: Int) -> Date {
//    let seconds: TimeInterval =  Double(minute) * 60 * (-1)
//    return lhs.addingTimeInterval(seconds)
//}
//
//public func -(lhs: Date, rhs: Date) -> TimeInterval {
//    return Double(lhs.minutesFrom(rhs) * 60)
//}

//extension Date: Comparable { }

public struct Rule{
    static let None = 0
    static let Cut = 1
    static let Force = 2
    static let Drop = 3
    static let Ignore = 4
}

public struct DurationInSeconds{
    static let Second = 1.0
    static let Minute = 60.0 * Second
    static let Hour = 60.0 * Minute
    static let Day = 24.0 * Hour
    static let Week = 7.0 * Day
}

// This class is the core model of the app.
// It makes all kinds of estimations and gives useful information about all actions.
class LazyBrain{
    var actions :[Action] = [Action]()
    var dataManager = DataManager()

    // This function returns an array of Int? representing estimated free time
    // in minutes. The size of the array will be same as number of actions in
    // actions array.
    func getEstimation()->[Int?]{
        actions = dataManager.fecthRepetitionActionList()
        return calculation(actions);
    }
    
    fileprivate struct Duration{
        static let Hour = 60
        static let Day = 24 * Hour
        static let Week = 7 * Day
    }
    

    
    // This is an algorithm to calculate etimated free time for each task 
    // It work as fellows:
    // 1. For all actions in the list, pick the task having nearest due date
    // 2. If the action is overdue, then do nothing
    // 3. Otherwise, add the first availiable date with the action estimated duration
    // to get the estimated finish date
    // 4. The free time should be due date - estimated finish date * (someOhterFactor)
    // 5. Change the First Available Date use nextAvailableDateCalculator
    // 6. Go to Step 1 till there is no more task.
    func calculation(_ actions: [Action])->[Int?]{
        var result = [Int?]()
        let habits = dataManager.loadData("Habit") as! [Habit]
        var firstAvailableDate = Date()
        for action in actions {
            var estimatedFreeDuration: Int?
            
            
            if let dueDate = action.value(forKey: "dueDate") as? Date {
                if !action.isOverdue() {
                    let estimatedFinishDate = firstAvailableDate + Double(estimateDuration(action)) * 60
                    let estimatedFinishDateWithHabit = estimatedFinishDate + calculateHabitDuration(habits, start: firstAvailableDate, end: estimatedFinishDate) // New Here!
                    estimatedFreeDuration = Int( Double(transformDueDate(dueDate).minutesFrom(estimatedFinishDateWithHabit) * 60) - safeZoneDuration(action)) / 60
                    
                   
                    
                    let rule = action.conflictResolvingRule
                    
                    if rule == Rule.Ignore || rule == Rule.Cut {
                        estimatedFreeDuration = 0
                    } else if rule == Rule.Drop {
                        estimatedFreeDuration = nil
                    }
                    
                    let prevFirstAvailableDate = firstAvailableDate
                    switch rule {
                    case Rule.Cut:
                        firstAvailableDate = transformDueDate(dueDate)
                    case Rule.Ignore:
                        firstAvailableDate = estimatedFinishDate
                    case Rule.Force:
                        firstAvailableDate = estimatedFinishDate
                    case Rule.None:
                        firstAvailableDate = estimatedFinishDate
                    default:
                        break
                    }
                    
                    // This is done after the conflicts are resolved. The order is crucial.
                    
                    firstAvailableDate = firstAvailableDate + calculateHabitDuration(habits, start: prevFirstAvailableDate, end: firstAvailableDate) // New Here!
                }
            }
            
            result.append(estimatedFreeDuration)
            
        }
        return result
    }
    
    // This function estimate the duration of action based on some policy 
    // Currently estimateDuration = userEstimatedDuration * accuracyRatio
    // where accurate = 1.05
    //       normal = 1.15
    //       unknown = 1.35
    internal func estimateDuration(_ action: Action)->Int{
        let durationDays = action.durationDays
        let durationMinutes = action.durationMinutes
        let completionRate = action.completionRate
        let duration = Double(durationDays * 60 * 24 + durationMinutes) * Double(1 - completionRate / 100)
        var accuracyRatio : Double = 1
        let accuracyValue = action.value(forKey: "accuracy") as! Int
        
        switch accuracyValue {
        case 0:
            accuracyRatio = 1.05 //accurate
        case 1:
            accuracyRatio = 1.15 //normal
        case 2:
            accuracyRatio = 1.35 //unkown
        default:
            break
        }
        
        let type = action.value(forKey: "type") as! Int
        if type == 0 {
            return Int(duration * accuracyRatio)
        } else {
            return Int(duration)
        }
    }
    
    
    // This function estimate the safe zone that must be left before the due date of 
    // a certain task 
    // Currently safeZoneDuration = userEstimatedDuration * importanceRatio + 15mins
    // where must = 0.25
    //       important = 0.1
    //       normal = 0.05
    internal func safeZoneDuration(_ action:Action)->TimeInterval{
        let type = action.value(forKey: "type") as! Int
        if type == 0 {
            let durationDays = action.value(forKey: "durationDays") as! Int
            let durationMinutes = action.value(forKey: "durationMinutes") as! Int
            let duration = Double(durationDays * 60 * 24 + durationMinutes) * 60
            let importance = action.value(forKey: "importance") as! Int
            var importanceRatio : Double = 0
            switch importance {
            case 0:
                importanceRatio = 0.25 //must
            case 1:
                importanceRatio = 0.1 //important
            case 2:
                importanceRatio = 0.05 //normal
            default:
                break
            }
            
            return duration * importanceRatio + 15 * 60
        } else {
            return 0
        }
    }
    
    // MARK: - Estimation Level Decoder
    
    // This function check if a given estimation means the task is in the state of "Conflict"
    // Return true if so, false otherwise.
    func isConflict(_ estimation: Int?)->Bool{
        if estimation == nil {
            return false
        } else if estimation! < -60 {
            return true
        }
        return false
    }
    
    // This function check if a given estimation means the task is in the state of "Start Now"
    // Return true if so, false otherwise. 
    func isToStart(_ estimation: Int?)->Bool{
        if estimation == nil {
            return false
        } else if -60 <= estimation! && estimation! < Int(60 * 1.5) {
            return true
        }
        return false
    }
    
    // This helper function transform the dueDate to correct estimated due date
    fileprivate func transformDueDate(_ dueDate: Date)->Date{
        for action in actions {
            let actionStartDate = (action.dueDate as Date) - Double(action.durationDays * Duration.Day) * 60  - Double(action.durationMinutes) * 60
            if  action.conflictResolvingRule == Rule.Force && actionStartDate < dueDate && dueDate < action.dueDate{
                return actionStartDate
            }
        }
        return dueDate
    }
    
    // MARK: - Week4
    // This helper function returns the all actions that has a rule
    internal func actionsWithRule(_ actions: [Action])->[Action] {
        var results = [Action]()
        for action in actions {
            if action.conflictResolvingRule != 0 {
                results.append(action)
            }
        }
        return results
    }
    
    //This function returns all the actions that have no rule, but having conflict. 
    internal func actionWithConflict(_ actions: [Action])->[Action] {
        var results = [Action]()
        var estimations = calculation(actions)
        for (i, action) in actions.enumerated() {
            if action.conflictResolvingRule == 0  && isConflict(estimations[i]){
                results.append(action)
            }
        }
        return results
    }
    
    //This function calculates the habit duration.
    func calculateHabitDuration(_ habits: [Habit], start: Date, end: Date)->TimeInterval{
        var result: TimeInterval = 0
        let duration = Double(end.minutesFrom(start) * 60)
        for habit in habits {
            let days = duration / DurationInSeconds.Day
            let habitDuration = days * habit.duration
            result += habitDuration
        }
        return result
    }
    
}
