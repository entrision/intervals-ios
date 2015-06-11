//
//  HWIntervalTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/18/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData
import XCTest

class HWIntervalTests: XCTestCase {
    
    var moc = NSManagedObjectContext()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let mom = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom!)
        do {
            try psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
        } catch _ {
        }
        moc.persistentStoreCoordinator = psc
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
