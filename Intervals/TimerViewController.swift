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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.startButton.layer.cornerRadius = 51.0
        self.timerBackgroundView.layer.cornerRadius = 134.0
        
        var error: NSError?
        let sequence = self.managedObjectContext.existingObjectWithID(self.sequenceID, error: &error) as! HWSequence
        self.sequenceNameLabel.text = sequence.name
        
        self.intervalArray = sequence.intervals.sortedArrayUsingDescriptors([NSSortDescriptor(key: "position", ascending: true)]) as NSArray
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParentViewController() {
            self.timer.invalidate()
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }

    @IBAction func startButtonTapped(sender: AnyObject) {
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateCountdown"), userInfo: nil, repeats: true)
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
            
            self.secondsLeft--;
            hours = self.secondsLeft / 3600;
            minutes = (self.secondsLeft % 3600) / 60;
            seconds = (self.secondsLeft % 3600) % 60;
            self.timerLabel.text = String(NSString(format: "%01d:%02d", minutes, seconds))
        }
        else {
            
            if self.currentIntervalIndex < self.intervalArray.count - 1 {
                
                self.currentIntervalIndex++
                let nextInterval = self.intervalArray[self.currentIntervalIndex] as! HWInterval
                self.secondsLeft = nextInterval.duration.integerValue
                
                self.intervalNameLabel.text = nextInterval.title
                
                let text = "\(self.intervalArray.indexOfObject(nextInterval)+1)"
                self.progressLabel.text = "\(text) of \(self.intervalArray.count)"
            }
            else {
                //finished
                self.scheduleLocalNotification(0, alertText: "Complete")
                self.timer.invalidate()
            }
        }
    }
    
    func scheduleLocalNotification(timeUntil: Int, alertText: String) {
        
        let localNotif = UILocalNotification()
        let date = NSDate(timeIntervalSinceNow: NSTimeInterval(timeUntil))
        localNotif.fireDate = date
//        localNotif.alertBody = alertText
        localNotif.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().scheduleLocalNotification(localNotif)
    }
}
