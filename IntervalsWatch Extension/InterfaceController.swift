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
    
    var sequenceDict = NSDictionary()
    var intervalArray = NSArray()
    var backgroundTimer = NSTimer()
    var currentIntervalIndex: Int = 0
    var startDate = NSDate()
    var pauseDate = NSDate()
    var intervalDuration: NSTimeInterval = 0
    
    var finished = false
    var ticking = false
    var delayed = false
    var paused = false
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        sequenceDict = context as! NSDictionary
        loadSequence()
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
            loadSequence()
            finished = false
            return
        }
        
        if paused {
            let timeElapsed: NSTimeInterval = pauseDate.timeIntervalSinceDate(startDate)
            intervalDuration = intervalDuration - timeElapsed
            paused = false
        }
        
        let date = NSDate(timeIntervalSinceNow: intervalDuration)
        timer.setDate(date)
        
        // Stop
        if ticking {
            
            timer.stop()
            backgroundTimer.invalidate()
            loadSequence()
            
            pauseButton.setEnabled(false)
            setTitleForButton(pauseButton, title: "Pause", color: UIColor.lightGrayColor())
            
            let lightBlue = UIColor(red: 0.0, green: 189.0/255.0, blue: 1.0, alpha: 1.0)
            intervalNameLabel.setTextColor(lightBlue)
            timer.setTextColor(lightBlue)
        }
        else { // Start
            
            timer.start()
            backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(intervalDuration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
            startDate = NSDate()
            
            setTitleForButton(startButton, title: "Stop", color: UIColor.redColor())
            pauseButton.setEnabled(true)
            setTitleForButton(pauseButton, title: "Pause", color: UIColor(red: 0, green: 0.35, blue: 1.0, alpha: 1.0))
        }
        
        self.ticking = !self.ticking
    }

    @IBAction func pauseButtonTapped() {
        
        //TODO: Implement
        timer.stop()
        backgroundTimer.invalidate()
        pauseDate = NSDate()
        
        pauseButton.setEnabled(false)
        setTitleForButton(pauseButton, title: "Pause", color: UIColor.lightGrayColor())
        
        setTitleForButton(startButton, title: "Start", color: UIColor.greenColor())
        ticking = false
        paused = true
    }
    
    //MARK: Private methods
    
    func loadSequence() {
        
        currentIntervalIndex = 0
        finished = false
        
        sequenceNameLabel.setText(sequenceDict["name"] as? String)
        
        intervalArray = sequenceDict["intervals"] as! NSArray
        
        let firstInterval = intervalArray[currentIntervalIndex] as! NSDictionary
        intervalNameLabel.setText(firstInterval["title"] as? String)
        progressLabel.setText("\(intervalArray.indexOfObject(firstInterval)+1) of \(intervalArray.count)")
        
        intervalDuration = NSTimeInterval(firstInterval["duration"] as! NSNumber) + 1
        let date = NSDate(timeIntervalSinceNow: intervalDuration)
        timer.setDate(date)
        
        timer.setHidden(false)
        intervalNameLabel.setHidden(false)
        progressLabel.setHidden(false)
        startButton.setHidden(false)
        setTitleForButton(startButton, title: "Start", color: UIColor.greenColor())
    }
    
    func nextInterval() {
        
        if delayed {
            
            let currentInterval = intervalArray[currentIntervalIndex] as! NSDictionary
            intervalDuration = NSTimeInterval(currentInterval["duration"] as! NSNumber)
            let date = NSDate(timeIntervalSinceNow: intervalDuration)
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
                
                intervalDuration = NSTimeInterval(sequenceDict["delay"] as! NSNumber)
                let date = NSDate(timeIntervalSinceNow: intervalDuration)
                timer.setDate(date)
                timer.start()
                delayed = true
                
            } else {
                
                intervalNameLabel.setText("Completed")
                setTitleForButton(startButton, title: "Reset", color: UIColor.orangeColor())
                progressLabel.setHidden(true)
                pauseButton.setEnabled(false)
                setTitleForButton(pauseButton, title: "Pause", color: UIColor.lightGrayColor())
                timer.stop()
                timer.setHidden(true)
                currentIntervalIndex = 0
                ticking = false
                finished = true
            }
        }
        
        if !finished {
            backgroundTimer = NSTimer.scheduledTimerWithTimeInterval(intervalDuration, target: self, selector: Selector("nextInterval"), userInfo: nil, repeats: false)
            startDate = NSDate()
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
