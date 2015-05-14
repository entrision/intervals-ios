//
//  BaseViewControllerTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import XCTest
import WatchCoreDataProxy

class BaseViewControllerTests: XCTestCase {
    
    var controller = BaseViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        controller.viewDidLoad()
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

    func testManagedObjectContext() {
        
        XCTAssertNotNil(controller.managedObjectContext, "BaseViewController's managedObjectContext not set")
        XCTAssertTrue(controller.managedObjectContext == WatchCoreDataProxy.sharedInstance.managedObjectContext, "Incorrect context for BaseViewController")
    }
}
