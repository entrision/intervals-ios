//
//  TimerViewControllerTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class TimerViewControllerTests: XCTestCase {
    
    var timerController = TimerViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        timerController = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType)).instantiateViewControllerWithIdentifier("TimerViewController") as! TimerViewController
        timerController.loadView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSuperclass() {
        
        XCTAssertTrue(timerController.isKindOfClass(BaseViewController.classForCoder()), "ViewController is not subclass of BaseViewController")
    }
}
