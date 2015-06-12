//
//  BaseViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData

class BaseViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext = NSManagedObjectContext()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = delegate.managedObjectContext
    }
}
