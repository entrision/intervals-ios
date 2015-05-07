//
//  BaseViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData
import WatchCoreDataProxy

class BaseViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext = NSManagedObjectContext()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        managedObjectContext = WatchCoreDataProxy.sharedInstance.managedObjectContext!
    }
}
