//
//  Sequence.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/21/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import CoreData

public class HWSequence: NSManagedObject {
    
    @NSManaged public var name: String
    @NSManaged public var intervals: NSSet
    @NSManaged public var position: NSNumber
    @NSManaged public var delay: NSNumber
    @NSManaged public var loadedOnWatch: NSNumber
}

extension HWSequence {
    public func addIntervalObject(value:HWInterval) {
        let items = self.mutableSetValueForKey("intervals");
        items.addObject(value)
    }
    
    public func removeIntervalObject(value:HWInterval) {
        let items = self.mutableSetValueForKey("intervals");
        items.removeObject(value)
    }
}
