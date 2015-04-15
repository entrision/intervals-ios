//
//  Sequence.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import CoreData

class Sequence: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var intervals: NSSet
}

extension Sequence {
    func addIntervalObject(value:Interval) {
        var items = self.mutableSetValueForKey("intervals");
        items.addObject(value)
    }
    
    func removeIntervalObject(value:Interval) {
        var items = self.mutableSetValueForKey("intervals");
        items.removeObject(value)
    }
}
