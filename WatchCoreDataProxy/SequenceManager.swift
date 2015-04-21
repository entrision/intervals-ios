//
//  SequenceManager.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/21/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import CoreData

public class SequenceManager: NSObject {
    
    public static let entityName = "Sequence"
    
    static let sharedInstance = SequenceManager()

    public class func createSequence(theSequence: HWSequence) {
        
        let context = WatchCoreDataProxy.sharedInstance.managedObjectContext
        var sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: context!) as! HWSequence
        sequence = theSequence
        
        var error: NSError?
        context?.save(&error)
    }
}
