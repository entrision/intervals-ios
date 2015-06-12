//
//  InputViewControllerTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import XCTest
@testable import Intervals

class InputViewControllerTests: XCTestCase {
    
    var controller = InputViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let navController = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType)).instantiateViewControllerWithIdentifier("InputNavController") as! UINavigationController
        controller = navController.viewControllers[0] as! InputViewController
        controller.loadView()
        controller.viewDidLoad()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSuperclass() {
        
        XCTAssertTrue(controller.isKindOfClass(BaseViewController.classForCoder()), "ViewController is not subclass of BaseViewController")
    }
    
    func testTableViewDelegateAndDataSource() {
        
        XCTAssertNotNil(controller.theTableView.delegate, "TableView delegate not set")
        XCTAssertNotNil(controller.theTableView.dataSource, "TableView data source not set")
    }
    
    func testReorderTableView() {
        
        XCTAssertTrue(controller.theTableView.isKindOfClass(ReorderTableView.classForCoder()), "TableView is not of class ReorderTableView")
    }
    
    func testForAddCell() {
        
        let result = controller.theTableView.numberOfRowsInSection(0)
        
        if controller.readOnly {
            
            if controller.editMode {
                XCTAssertTrue(result == controller.intervalArray.count+1, "Add cell not present in InputViewController")
            }
        }
        else {
            XCTAssertTrue(result == controller.intervalArray.count+1, "Add cell not present in InputViewController")
        }
    }

}
