//
//  LazyModeTests.swift
//  LazyModeTests
//
//  Created by Work on 4/5/16.
//  Copyright © 2016 whileAliveWork. All rights reserved.
//

import XCTest
@testable import LazyMode

// constants of Double(as NSTimeInterval) representing Duration in seconds
public struct DurationInSeconds{
    static let Minute: Double = 60
    static let Hour = 60 * Minute
    static let Day = 24 * Hour
    static let Week = 7 * Day
}

// constants of Int representing Duration in minuites
public struct DurationInMinutes{
    static let Hour = 60
    static let Day = 24 * Hour
    static let Week = 7 * Day
}

class LazyModeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsConflict(){
        let lazyBrain = LazyBrain()
        XCTAssertTrue(lazyBrain.isConflict(-100))
        XCTAssertFalse(lazyBrain.isConflict(-50))
        XCTAssertFalse(lazyBrain.isConflict(0))
        XCTAssertFalse(lazyBrain.isConflict(100))
        XCTAssertFalse(lazyBrain.isConflict(nil))
        
    }
    
    func testIsToStart(){
        let lazyBrain = LazyBrain()
        XCTAssertFalse(lazyBrain.isToStart(-100))
        XCTAssertFalse(lazyBrain.isToStart(-61))
        XCTAssertTrue(lazyBrain.isToStart(-60))
        XCTAssertTrue(lazyBrain.isToStart(10))
        XCTAssertFalse(lazyBrain.isToStart(1000))
        XCTAssertFalse(lazyBrain.isToStart(nil))
    }
    
    func testSafeZoneDuration(){
        let lazyBrain = LazyBrain()
        let action = Action(intervalFromNow: DurationInSeconds.Week, completionRate: 0, durationDays: 0, durationMinutes: 2 * DurationInMinutes.Hour)
        // 2 hours duration 
        // thus 2 hours * mustSafeRaio(0.25) + 15mins
        XCTAssertEqual(lazyBrain.safeZoneDuration(action), 0.25 * 2 * DurationInSeconds.Hour + 15 * DurationInSeconds.Minute)
        XCTAssertNotEqual(lazyBrain.safeZoneDuration(action), 0)
    }
    
    
    func testEstimateDuration(){
        let lazyBrain = LazyBrain()
        let action = Action(intervalFromNow: DurationInSeconds.Week, completionRate: 0, durationDays: 0, durationMinutes: 2 * DurationInMinutes.Hour)
        XCTAssertEqual(lazyBrain.estimateDuration(action), Int(Double(2 * DurationInMinutes.Hour) * 1.05))
        XCTAssertNotEqual(lazyBrain.estimateDuration(action), 0)
    }
    
    func testCalculation(){
        let lazyBrain = LazyBrain()
        var actions = [Action]()
        actions.append(Action(intervalFromNow: 4 * DurationInSeconds.Hour, completionRate: 0, durationDays: 0, durationMinutes: 2 * DurationInMinutes.Hour))
        XCTAssertEqual(lazyBrain.calculation(actions)[0], 68)
        // 68 instead of 67 because of the seconds offset of NSDate(), but it's accurate enough though.
        
    }
}
