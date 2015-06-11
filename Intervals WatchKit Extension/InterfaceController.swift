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

    @IBOutlet weak var sequenceTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var intervalTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var progressLabel: WKInterfaceLabel!
    @IBOutlet weak var startButton: WKInterfaceButton!
    @IBOutlet weak var timer: WKInterfaceTimer!
    
    var intervalArray = NSArray()
    var backgroundTimer = NSTimer()
    
    var sequenceID: NSManagedObjectID = NSManagedObjectID()
    var currentIntervalIndex: Int = 0
    
    var ticking = false
    var finished = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        Callback.addObjectivecObserver(self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    internal func sequenceLoaded() {
        
        // Sequence fetch
        let seqEntityDesc = NSEntityDescription.entityForName("Sequence", inManagedObjectContext: WatchCoreDataProxy.sharedInstance.managedObjectContext!)
        let seqRequest: NSFetchRequest = NSFetchRequest()
        seqRequest.entity = seqEntityDesc

        let seqPredicate = NSPredicate(format: "loadedOnWatch == 1")
        seqRequest.predicate = seqPredicate

        let array = (try! WatchCoreDataProxy.sharedInstance.managedObjectContext!.executeFetchRequest(seqRequest)) as NSArray

        let sequence: HWSequence = array[0] as! HWSequence
        self.sequenceID = sequence.objectID
        self.sequenceTitleLabel.setText(sequence.name)
        
        // Interval fetch
        let intervalEntityDesc = NSEntityDescription.entityForName("Interval", inManagedObjectContext: WatchCoreDataProxy.sharedInstance.managedObjectContext!)
        let intervalRequest: NSFetchRequest = NSFetchRequest()
        intervalRequest.entity = intervalEntityDesc
        
        let intervalPredicate = NSPredicate(format: "sequence = %@", sequence)
        intervalRequest.predicate = intervalPredicate
        
        let sort = NSSortDescriptor(key: "position", ascending: true)
        intervalRequest.sortDescriptors = [sort]

        self.intervalArray = (try! WatchCoreDataProxy.sharedInstance.managedObjectContext!.executeFetchRequest(intervalRequest)) as NSArray
        let firstInterval = self.intervalArray[0] as! HWInterval
        WatchCoreDataProxy.sharedInstance.managedObjectContext?.refreshObject(firstInterval, mergeChanges: true)
        
        let intervalTitle = firstInterval.title
        self.intervalTitleLabel.setText(intervalTitle)
        
        let text = "\(self.intervalArray.indexOfObject(firstInterval)+1)"
        self.progressLabel.setText("\(text) of \(self.intervalArray.count)")

        let duration = NSTimeInterval(firstInterval.duration.integerValue) + 1
        let date = NSDate(timeIntervalSinceNow: duration)
        self.timer.setDate(date)
        self.timer.setHidden(false)
        
        self.startButton.setHidden(false)
        self.setStartButtonTitle("Start", color: UIColor.greenColor())
        self.currentIntervalIndex = 0
        self.finished = false
        
        // Couldn't figure out why the following code won't detect changes to relationship objects. 
        // Keeping for now to hopefully figure out the cause.
        
//        let entityDesc = NSEntityDescription.entityForName("Sequence", inManagedObjectContext: WatchCoreDataProxy.sharedInstance.managedObjectContext!)
//        let request: NSFetchRequest = NSFetchRequest()
//        request.entity = entityDesc
//        
//        let predicate = NSPredicate(format: "loadedOnWatch == 1")
//        request.predicate = predicate
//        
//        var error: NSError?
//        let array = WatchCoreDataProxy.sharedInstance.managedObjectContext!.executeFetchRequest(request, error: &error)! as NSArray
//        
//        let sequence: HWSequence = array[0] as! HWSequence
//        self.sequenceID = sequence.objectID
//        self.sequenceTitleLabel.setText(sequence.name)
//
//        self.intervalArray = sequence.intervals.sortedArrayUsingDescriptors([NSSortDescriptor(key: "position", ascending: true)]) as NSArray
//        let firstInterval = self.intervalArray.objectAtIndex(0) as! HWInterval
//        
//        let title = firstInterval.title
//        self.intervalTitleLabel.setText(title)
//        
//        let text = "\(self.intervalArray.indexOfObject(firstInterval)+1)"
//        self.progressLabel.setText("\(text) of \(self.intervalArray.count)")
//        
//        let duration = NSTimeInterval(firstInterval.duration.integerValue) + 1
//        let date = NSDate(timeIntervalSinceNow: duration)
//        self.timer.setDate(date)
    }

    @IBAction func startButtonTapped() {
        
        // Reset
        if self.finished {
            self.sequenceLoaded()
            self.finished = false
            return
        }

        let interval = self.intervalArray[self.currentIntervalIndex] as! HWInterval
        
        let duration = NSTimeInterval(interval.duration.integerValue)
        let date = NSDate(timeIntervalSinceNow: duration)
        self.timer.setDate(date)
        
        // Stop
        if self.ticking {
            
            self.timer.stop()
            self.backgroundTimer.invalidate()
            self.sequenceLoaded()
            
        }
        else { // Start
            
            self.timer.start()
            self.backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
            self.setStartButtonTitle("Stop", color: UIColor.redColor())
        }
        
        self.ticking = !self.ticking
    }
    
    func nextInterval() {
        
        if self.currentIntervalIndex < self.intervalArray.count-1 {
            
            self.currentIntervalIndex++
            
            let nextInterval = self.intervalArray[self.currentIntervalIndex] as! HWInterval
            
            self.intervalTitleLabel.setText(nextInterval.title)
            WatchCoreDataProxy.sharedInstance.managedObjectContext?.refreshObject(nextInterval, mergeChanges: true)
            
            let text = "\(intervalArray.indexOfObject(nextInterval)+1)"
            self.progressLabel.setText("\(text) of \(intervalArray.count)")
            
            let duration = NSTimeInterval(nextInterval.duration.integerValue)
            let date = NSDate(timeIntervalSinceNow: duration)
            self.timer.setDate(date)
            self.timer.start()
            
            self.backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
        }
        else {
            
            self.intervalTitleLabel.setText("Completed")
            self.progressLabel.setText("")
            self.timer.setHidden(true)
            self.timer.stop()
            self.setStartButtonTitle("Reset", color: UIColor.orangeColor())
            self.currentIntervalIndex = 0
            self.ticking = false
            self.finished = true
        }
    }
    
    func setStartButtonTitle(title: String, color: UIColor) {
        
        let string: NSMutableAttributedString = NSMutableAttributedString(string: title)
        let attributes = [NSForegroundColorAttributeName: color]
        string.setAttributes(attributes, range:NSMakeRange(0, string.length))
        self.startButton.setAttributedTitle(string)
    }
}
