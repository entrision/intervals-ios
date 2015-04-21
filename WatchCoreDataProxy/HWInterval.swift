//
//  Interval.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/21/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import CoreData

public class HWInterval: NSManagedObject {
    
    @NSManaged public var title: String
    @NSManaged public var duration: NSNumber
    @NSManaged public var minutes: NSNumber
    @NSManaged public var seconds: NSNumber
    @NSManaged public var position: NSNumber
    @NSManaged public var sequence: HWSequence
}
