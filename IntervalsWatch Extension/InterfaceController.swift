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
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var pauseButton: WKInterfaceButton!
    
    let wcSession = WCSession.defaultSession()
    
    var messageDict = NSDictionary()
    var intervalArray = NSArray()
    var backgroundTimer = NSTimer()
    var currentIntervalIndex: Int = 0
    
    var finished = false
    var ticking = false
    var delayed = false
    
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
            
            pauseButton.setEnabled(false)
            setTitleForButton(pauseButton, title: "Pause", color: UIColor.lightGrayColor())
        }
        else { // Start
            
            timer.start()
            backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
            
            setTitleForButton(startButton, title: "Stop", color: UIColor.redColor())
            pauseButton.setEnabled(true)
            setTitleForButton(pauseButton, title: "Pause", color: UIColor(red: 0, green: 0.35, blue: 1.0, alpha: 1.0))
        }
        
        self.ticking = !self.ticking
    }

    @IBAction func pauseButtonTapped() {
        
        //TODO: Implement
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
        startButton.setHidden(false)
        setTitleForButton(startButton, title: "Start", color: UIColor.greenColor())
    }
    
    func nextInterval() {
            
        var duration: NSTimeInterval = 0
        if delayed {
            
            let currentInterval = intervalArray[currentIntervalIndex] as! NSDictionary
            duration = NSTimeInterval(currentInterval["duration"] as! NSNumber)
            let date = NSDate(timeIntervalSinceNow: duration)
            timer.setDate(date)
            timer.start()
            delayed = false
            
            let lightBlue = UIColor(red: 0.0, green: 189.0/255.0, blue: 1.0, alpha: 1.0)
            intervalNameLabel.setTextColor(lightBlue)
            timer.setTextColor(lightBlue)
            
        } else {
            
            if currentIntervalIndex < intervalArray.count-1 {
                
                currentIntervalIndex++
                let nextInterval = intervalArray[currentIntervalIndex] as! NSDictionary
                
                intervalNameLabel.setText(nextInterval["title"] as? String)
                intervalNameLabel.setTextColor(UIColor.greenColor())
                timer.setTextColor(UIColor.greenColor())
                
                let text = "\(intervalArray.indexOfObject(nextInterval)+1)"
                self.progressLabel.setText("\(text) of \(intervalArray.count)")
                
                let sequenceDict = messageDict["sequence"] as! NSDictionary
                duration = NSTimeInterval(sequenceDict["delay"] as! NSNumber)
                let date = NSDate(timeIntervalSinceNow: duration)
                timer.setDate(date)
                timer.start()
                delayed = true
                
            } else {
                
                intervalNameLabel.setText("Completed")
                timer.stop()
                setTitleForButton(startButton, title: "Reset", color: UIColor.orangeColor())
                currentIntervalIndex = 0
                ticking = false
                finished = true
            }
        }
        
        if !finished {
            backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
        }

        WKInterfaceDevice.currentDevice().playHaptic(WKHapticType.Start)
    }
    
    func setTitleForButton(button: WKInterfaceButton, title: String, color: UIColor) {
        
        let string: NSMutableAttributedString = NSMutableAttributedString(string: title)
        let attributes = [NSForegroundColorAttributeName: color]
        string.setAttributes(attributes, range:NSMakeRange(0, string.length))
        button.setAttributedTitle(string)
    }
}

//MARK: WCSessionDelegate
extension InterfaceController : WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        messageDict = message
        sequenceLoaded()
    }
}
