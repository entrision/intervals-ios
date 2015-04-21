//
//  InterfaceController.swift
//  Intervals WatchKit Extension
//
//  Created by Hunter Whittle on 4/20/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import WatchKit
import Foundation
import CoreData
import WatchCoreDataProxy

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var progressLabel: WKInterfaceLabel!
    @IBOutlet weak var timer: WKInterfaceTimer!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        Callback.objectivecObserver(self)
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    internal func sequenceLoaded() {
        
        let entityDesc = NSEntityDescription.entityForName("Sequence", inManagedObjectContext: WatchCoreDataProxy.sharedInstance.managedObjectContext!)
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entityDesc
        
        let predicate = NSPredicate(format: "loadedOnWatch == 1")
        request.predicate = predicate
        
        var error: NSError?
        let array = WatchCoreDataProxy.sharedInstance.managedObjectContext!.executeFetchRequest(request, error: &error)! as NSArray
        
        let sequence: HWSequence = array[0] as! HWSequence
        let intervalArray = sequence.intervals.sortedArrayUsingDescriptors([NSSortDescriptor(key: "position", ascending: true)]) as NSArray
        let firstInterval = intervalArray.objectAtIndex(0) as! HWInterval
        let title = firstInterval.title
        self.titleLabel.setText(title)
        
        let text = "\(intervalArray.indexOfObject(firstInterval)+1)"
        self.progressLabel.setText("\(text) of \(intervalArray.count)")
        
        let duration = NSTimeInterval(firstInterval.duration.integerValue) + 1
        let date = NSDate(timeIntervalSinceNow: duration)
        self.timer.setDate(date)
    }

}
