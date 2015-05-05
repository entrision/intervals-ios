//
//  TimerViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/29/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData
import WatchCoreDataProxy

class TimerViewController: BaseViewController {
    
    @IBOutlet weak var sequenceNameLabel: UILabel!
    @IBOutlet weak var intervalNameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var timerBackgroundView: UIView!
    
    var sequenceID: NSManagedObjectID = NSManagedObjectID()
    
    var intervalArray = NSArray()
    var currentIntervalIndex: Int = 0
    var timer = NSTimer()
    var secondsLeft: Int = 0
    
    var toBackgroundDate = NSDate()
    var timeElapsedInBackground: Int = 0
    var delayed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.startButton.layer.cornerRadius = 51.0
        self.timerBackgroundView.layer.cornerRadius = 134.0

        self.sequenceNameLabel.text = getSequence().name
        
        self.intervalArray = getSequence().intervals.sortedArrayUsingDescriptors([NSSortDescriptor(key: "position", ascending: true)]) as NSArray
        let firstInterval = self.intervalArray[self.currentIntervalIndex] as! HWInterval
        
        self.intervalNameLabel.text = firstInterval.title
        
        let text = "\(self.intervalArray.indexOfObject(firstInterval)+1)"
        self.progressLabel.text = "\(text) of \(self.intervalArray.count)"
        
        let minutes = firstInterval.minutes.integerValue
        let seconds = firstInterval.seconds.integerValue
        let timerString = NSString(format: "%d:%02d", minutes, seconds)
        self.timerLabel.text = String(timerString)
        
        self.secondsLeft = firstInterval.duration.integerValue
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("applicationWillEnterForeground:"), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = false
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
        
        if self.isMovingFromParentViewController() {
            self.timer.invalidate()
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }

    @IBAction func startButtonTapped(sender: AnyObject) {
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateCountdown"), userInfo: nil, repeats: true)
    }
    
    func updateCountdown() {
        
        var hours: Int
        var minutes: Int
        var seconds: Int
        
        if self.secondsLeft > 0 {
            
            if UIApplication.sharedApplication().scheduledLocalNotifications.count < 1 {
                
                if self.currentIntervalIndex < self.intervalArray.count - 1 {
                    let upcomingInterval = self.intervalArray[self.currentIntervalIndex + 1] as! HWInterval
                    self.scheduleLocalNotification(self.secondsLeft, alertText: upcomingInterval.title)
                }
            }
            
            let currentInterval = intervalArray[self.currentIntervalIndex] as! HWInterval
            intervalNameLabel.text = currentInterval.title
            
            let text = "\(intervalArray.indexOfObject(currentInterval)+1)"
            progressLabel.text = "\(text) of \(intervalArray.count)"
            
            self.secondsLeft--;
            hours = self.secondsLeft / 3600;
            minutes = (self.secondsLeft % 3600) / 60;
            seconds = (self.secondsLeft % 3600) % 60;
            
            let formatString = delayed ? "-%01d:%02d" : "%01d:%02d"
            self.timerLabel.text = String(NSString(format: formatString, minutes, seconds))
        }
        else {
            
            if getSequence().delay.integerValue > 0 {
                
                if delayed {
                    let currentInterval = intervalArray[self.currentIntervalIndex] as! HWInterval
                    secondsLeft = currentInterval.duration.integerValue
                    delayed = false
                }
                else {
                    
                    if self.currentIntervalIndex < self.intervalArray.count - 1 {
                        nextInterval()
                        secondsLeft = getSequence().delay.integerValue
                        delayed = true
                    }
                    else {
                        finished()
                    }
                }
            }
            else {
                
                if self.currentIntervalIndex < self.intervalArray.count - 1 {
                    nextInterval()
                }
                else {
                    finished()
                }
            }
        }
    }
    
    func nextInterval() {
        self.currentIntervalIndex++
        let nextInterval = self.intervalArray[self.currentIntervalIndex] as! HWInterval
        self.intervalNameLabel.text = nextInterval.title
        self.secondsLeft = nextInterval.duration.integerValue
        let text = "\(self.intervalArray.indexOfObject(nextInterval)+1)"
        self.progressLabel.text = "\(text) of \(self.intervalArray.count)"
    }
    
    func finished() {
        self.scheduleLocalNotification(0, alertText: "Complete")
        self.timer.invalidate()
    }
    
    func scheduleLocalNotification(timeUntil: Int, alertText: String) {
        
        let localNotif = UILocalNotification()
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(timeUntil))
        localNotif.fireDate = date
        localNotif.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
    }
    
    //MARK: Notifications
    
    func applicationDidEnterBackground(notification: NSNotification) {
        
        timer.invalidate()
        toBackgroundDate = NSDate()
    }
    
    func applicationWillEnterForeground(notification: NSNotification) {
        
        timeElapsedInBackground = Int(NSDate().timeIntervalSinceDate(toBackgroundDate))
        
        var duration = 0
        var totalDuration = 0
        var newIntervalIndex = currentIntervalIndex
        var newSecondsLeft = secondsLeft - timeElapsedInBackground
        for var i=currentIntervalIndex; i<intervalArray.count; i++ {
            
            let theInterval = intervalArray[i] as! HWInterval
            totalDuration += theInterval.duration.integerValue
            
            if i == currentIntervalIndex {
                duration = secondsLeft
            } else {
                duration += theInterval.duration.integerValue
            }
        
            if timeElapsedInBackground > duration {
                newIntervalIndex++
                if newIntervalIndex < intervalArray.count {
                    let newInterval = intervalArray[newIntervalIndex] as! HWInterval
                    newSecondsLeft = newInterval.duration.integerValue - (timeElapsedInBackground - totalDuration)
                } else {
                    //Sequence completed
                }
            }
        }
        
        currentIntervalIndex = newIntervalIndex
        secondsLeft = newSecondsLeft
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateCountdown"), userInfo: nil, repeats: true)
    }
    
    func getSequence() -> HWSequence {
        var error: NSError?
        let sequence = self.managedObjectContext.existingObjectWithID(self.sequenceID, error: &error) as! HWSequence
        return sequence
    }
}
