//
//  ReorderTableViewTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/18/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import XCTest

class ReorderTableViewTests: XCTestCase {
    
    var tableView = UITableView()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let navController = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType)).instantiateViewControllerWithIdentifier("MainViewController") as! UINavigationController
        let controller = navController.viewControllers[0] as! ViewController
        controller.loadView()
        controller.viewDidLoad()
        tableView = controller.theTableView
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGestureRecognizer() {
        
        let count = tableView.gestureRecognizers?.count
        XCTAssertTrue(count > 0, "ReorderTableView is missing gesture recognizer")
    }
    
    
}
