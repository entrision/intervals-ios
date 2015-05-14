//
//  TimerViewControllerTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import XCTest

class TimerViewControllerTests: XCTestCase {
    
    var timerController = TimerViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        timerController = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType)).instantiateViewControllerWithIdentifier("TimerViewController") as! TimerViewController
        timerController.loadView()
        timerController.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}
