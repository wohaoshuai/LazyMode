//
//  Habit.swift
//  LazyMode
//
//  Created by Tony on 4/29/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import Foundation
import CoreData

class Habit: NSManagedObject{
    @NSManaged var name: String
    @NSManaged var type: Int
    @NSManaged var duration: Double
    
    
    
    // Saves the state
    func saveContext(){
        do {
            try self.managedObjectContext?.save()
        } catch {
            let saveError = error as NSError
            print(saveError)
        }
    }
}