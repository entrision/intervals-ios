//
//  HWSequenceTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/18/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import CoreData
import XCTest

class HWSequenceTests: XCTestCase {
    
    var moc = NSManagedObjectContext()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let mom = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom!)
        psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: nil)
        moc.persistentStoreCoordinator = psc
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
