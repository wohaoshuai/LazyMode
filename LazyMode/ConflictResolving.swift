//
//  RepeatingResolving.swift
//  LazyMode
//
//  Created by Tony on 4/25/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//


// Representing a conflict resolving rule for a virutal aciton
import UIKit
import CoreData
class ConflictResolving: NSManagedObject {
    @NSManaged var conflictResolvingRule: Int
    @NSManaged var dueDate: Date
    @NSManaged var uuid: String
    
}
