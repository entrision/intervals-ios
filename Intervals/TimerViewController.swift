//
//  TimerViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/29/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData

class TimerViewController: BaseViewController {
    
    @IBOutlet weak var sequenceNameLabel: UILabel!
    @IBOutlet weak var intervalNameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var sequenceID: NSManagedObjectID = NSManagedObjectID()
    
    var intervalArray = NSArray()
    var currentIntervalIndex: Int = 0
    var timer = NSTimer()
    var secondsLeft: Int = 0
    
    var toBackgroundDate = NSDate()
    var timeElapsedInBackground: Int = 0
    var delayed = false
    var ticking = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.startButton.layer.cornerRadius = 51.0
        self.pauseButton.layer.cornerRadius = 51.0

        self.sequenceNameLabel.text = getSequence().name
        
        self.intervalArray = getSequence().intervals.sortedArrayUsingDescriptors([NSSortDescriptor(key: "position", ascending: true)]) as NSArray
        loadIntervals()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("applicationDidEnterBackground:"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
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
        
        if ticking {
            startButton.setTitle("Start", forState: UIControlState.Normal)
            startButton.setTitleColor(Colors.intervalsGreen, forState: UIControlState.Normal)
            pauseButton.enabled = false
            timer.invalidate()
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            loadIntervals()
            ticking = false
        }
        else {
            startButton.setTitle("Stop", forState: UIControlState.Normal)
            startButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
            pauseButton.enabled = true
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateCountdown"), userInfo: nil, repeats: true)
            ticking = true
        }
    }
    
    @IBAction func pauseButtonTapped(sender: AnyObject) {
        pauseTimer()
    }
    
    func updateCountdown() {
        
        var minutes: Int
        var seconds: Int
        
        if self.secondsLeft > 0 {
            
            if UIApplication.sharedApplication().scheduledLocalNotifications!.count < 1 {
                
                if self.currentIntervalIndex < self.intervalArray.count - 1 && !delayed {
                    let upcomingInterval = intervalArray[self.currentIntervalIndex + 1] as! HWInterval
                    self.scheduleLocalNotification(self.secondsLeft, alertText: upcomingInterval.title)
                }
            }
            
            let currentInterval = intervalArray[self.currentIntervalIndex] as! HWInterval
            intervalNameLabel.text = currentInterval.title
            
            let text = "\(intervalArray.indexOfObject(currentInterval)+1)"
            progressLabel.text = "\(text) of \(intervalArray.count)"
            
            self.secondsLeft--;
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
                    self.intervalNameLabel.textColor = Colors.intervalsLightBlue
                    delayed = false
                }
                else {
                    
                    if self.currentIntervalIndex < self.intervalArray.count - 1 {
                        nextInterval()
                        secondsLeft = getSequence().delay.integerValue
                        self.intervalNameLabel.textColor = Colors.intervalsGreen
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
    
    func pauseTimer() {
        startButton.setTitle("Start", forState: UIControlState.Normal)
        startButton.setTitleColor(Colors.intervalsGreen, forState: UIControlState.Normal)
        pauseButton.enabled = false
        timer.invalidate()
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        ticking = false
    }
    
    func finished() {
        self.scheduleLocalNotification(0, alertText: "Complete")
        self.timer.invalidate()
        pauseButton.enabled = false
        currentIntervalIndex = 0
        startButton.setTitle("Reset", forState: UIControlState.Normal)
        startButton.setTitleColor(UIColor.orangeColor(), forState: UIControlState.Normal)
        self.intervalNameLabel.text = "Complete"
    }
    
    func scheduleLocalNotification(timeUntil: Int, alertText: String) {
        
        let localNotif = UILocalNotification()
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(timeUntil))
        localNotif.fireDate = date
        localNotif.soundName = "interval_effect.m4a"
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
    }
    
    //MARK: Notifications
    
    func applicationDidEnterBackground(notification: NSNotification) {
        
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        if ticking {
            pauseTimer()
        }
    }
    
    func loadIntervals() {
        
        let firstInterval = intervalArray[0] as! HWInterval
        
        intervalNameLabel.text = firstInterval.title
        
        let text = "\(intervalArray.indexOfObject(firstInterval)+1)"
        progressLabel.text = "\(text) of \(intervalArray.count)"
        
        let minutes = firstInterval.minutes.integerValue
        let seconds = firstInterval.seconds.integerValue
        let timerString = NSString(format: "%d:%02d", minutes, seconds)
        timerLabel.text = String(timerString)
        
        secondsLeft = firstInterval.duration.integerValue
    }
    
    func getSequence() -> HWSequence {
        
        do {
            let sequence = try self.managedObjectContext.existingObjectWithID(self.sequenceID) as! HWSequence
            return sequence
        } catch {
            return HWSequence()
        }
    }
}
