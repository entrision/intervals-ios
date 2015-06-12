//
//  ViewControllerTests.swift
//  Intervals
//
//  Created by Hunter Whittle on 5/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import XCTest
@testable import Intervals

class ViewControllerTests: XCTestCase {
    
    var controller = ViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let navController = UIStoryboard(name: "Main", bundle: NSBundle(forClass: self.dynamicType)).instantiateViewControllerWithIdentifier("MainViewController") as! UINavigationController
        controller = navController.viewControllers[0] as! ViewController
        controller.loadView()
        controller.viewDidLoad()
        controller.viewDidAppear(false)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSuperclass() {
        
        XCTAssertTrue(controller.isKindOfClass(BaseViewController.classForCoder()), "ViewController is not subclass of BaseViewController")
    }
    
    func testCustomTransitionDelegate() {
        
        XCTAssertTrue(controller.conformsToProtocol(UIViewControllerTransitioningDelegate), "ViewController does not conform to UIViewControllerTransitioningDelegate")
    }

    func testTableViewDelegateAndDataSource() {
        
        XCTAssertNotNil(controller.theTableView.delegate, "TableView delegate not set")
        XCTAssertNotNil(controller.theTableView.dataSource, "TableView data source not set")
    }
    
    func testReorderTableView() {
        
        XCTAssertTrue(controller.theTableView.isKindOfClass(ReorderTableView.classForCoder()), "TableView is not of class ReorderTableView")
        XCTAssertTrue(controller.theTableView.reorderEnabled, "Reordering should be enabled on ViewController TableView")
    }
    
    func testFetchSequences() {
        
        controller.fetchSequences()
        XCTAssertTrue(controller.sequenceArray.count > 0, "No sequences")
    }
    
    func testReorderTableViewSourceArray() {
        
        XCTAssertTrue(controller.theTableView.sourceArray == controller.sequenceArray, "ReorderTableView Source Array not equal to sequence array")
    }
    
    func testBarButtonItems() {
        
        let count = controller.navigationItem.rightBarButtonItems?.count
        XCTAssertTrue(count > 0, "ViewController should have 1 right bar button item (plus)")
    }
}
