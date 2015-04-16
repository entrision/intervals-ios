//
//  Interval.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import CoreData

class Interval: NSManagedObject {
   
    @NSManaged var title: NSString
    @NSManaged var duration: NSNumber
    @NSManaged var minutes: NSNumber
    @NSManaged var seconds: NSNumber
    @NSManaged var position: NSNumber
    @NSManaged var sequence: Sequence
}
