//
//  InterfaceController.swift
//  IntervalsWatch Extension
//
//  Created by Hunter Whittle on 6/11/15.
//  Copyright © 2015 Hunter Whittle. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet var sequenceNameLabel: WKInterfaceLabel!
    @IBOutlet var intervalNameLabel: WKInterfaceLabel!
    @IBOutlet var progressLabel: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var actionButton: WKInterfaceButton!
    
    let wcSession = WCSession.defaultSession()
    
    var messageDict = NSDictionary()
    var intervalArray = NSArray()
    var backgroundTimer = NSTimer()
    var currentIntervalIndex: Int = 0
    
    var finished = false
    var ticking = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        wcSession.delegate = self
        wcSession.activateSession()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: Actions
    
    @IBAction func startButtonTapped() {
        
        // Reset
        if finished {
            sequenceLoaded()
            finished = false
            return
        }
        
        let intervalDict = intervalArray[currentIntervalIndex] as! NSDictionary
        
        let duration = NSTimeInterval(intervalDict["duration"] as! NSNumber)
        let date = NSDate(timeIntervalSinceNow: duration)
        timer.setDate(date)
        
        // Stop
        if ticking {
            
            timer.stop()
            backgroundTimer.invalidate()
            sequenceLoaded()
            
        }
        else { // Start
            
            timer.start()
            backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
            setStartButtonTitle("Stop", color: UIColor.redColor())
        }
        
        self.ticking = !self.ticking
    }
    
    //MARK: Private methods
    
    func sequenceLoaded() {
        
        currentIntervalIndex = 0
        finished = false
        
        let sequenceDict = messageDict["sequence"] as! NSDictionary
        sequenceNameLabel.setText(sequenceDict["name"] as? String)
        
        intervalArray = messageDict["intervals"] as! NSArray
        
        let firstInterval = intervalArray[currentIntervalIndex] as! NSDictionary
        intervalNameLabel.setText(firstInterval["title"] as? String)
        progressLabel.setText("\(intervalArray.indexOfObject(firstInterval)+1) of \(intervalArray.count)")
        
        let duration = NSTimeInterval(firstInterval["duration"] as! NSNumber) + 1
        let date = NSDate(timeIntervalSinceNow: duration)
        timer.setDate(date)
        
        timer.setHidden(false)
        intervalNameLabel.setHidden(false)
        progressLabel.setHidden(false)
        actionButton.setHidden(false)
        setStartButtonTitle("Start", color: UIColor.greenColor())
    }
    
    func nextInterval() {
        
        if currentIntervalIndex < intervalArray.count-1 {
            
            currentIntervalIndex++
            
            let nextInterval = intervalArray[currentIntervalIndex] as! NSDictionary
            
            intervalNameLabel.setText(nextInterval["title"] as? String)
            
            let text = "\(intervalArray.indexOfObject(nextInterval)+1)"
            self.progressLabel.setText("\(text) of \(intervalArray.count)")
            
            let duration = NSTimeInterval(nextInterval["duration"] as! NSNumber)
            let date = NSDate(timeIntervalSinceNow: duration)
            self.timer.setDate(date)
            self.timer.start()
            
            backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
        }
        else {
            
            intervalNameLabel.setText("Completed")
            timer.stop()
            setStartButtonTitle("Reset", color: UIColor.orangeColor())
            currentIntervalIndex = 0
            ticking = false
            finished = true
        }
        
        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Start)
    }
    
    func setStartButtonTitle(title: String, color: UIColor) {
        
        let string: NSMutableAttributedString = NSMutableAttributedString(string: title)
        let attributes = [NSForegroundColorAttributeName: color]
        string.setAttributes(attributes, range:NSMakeRange(0, string.length))
        actionButton.setAttributedTitle(string)
    }
}

//MARK: WCSessionDelegate
extension InterfaceController : WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        messageDict = message
        sequenceLoaded()
    }
}
