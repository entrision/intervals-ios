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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.startButton.layer.cornerRadius = 51.0
        self.timerBackgroundView.layer.cornerRadius = 134.0
        
        var error: NSError?
        let sequence = self.managedObjectContext.existingObjectWithID(self.sequenceID, error: &error) as! HWSequence
        self.sequenceNameLabel.text = sequence.name
        
        let intervalArray = sequence.intervals.sortedArrayUsingDescriptors([NSSortDescriptor(key: "position", ascending: true)]) as NSArray
        let firstInterval = intervalArray[0] as! HWInterval
        
        self.intervalNameLabel.text = firstInterval.title
        
        let text = "\(intervalArray.indexOfObject(firstInterval)+1)"
        self.progressLabel.text = "\(text) of \(intervalArray.count)"
        
        let minutes = firstInterval.minutes.integerValue
        let seconds = firstInterval.seconds.integerValue
        let timerString = NSString(format: "%d:%02d", minutes, seconds)
        self.timerLabel.text = String(timerString)
    }


}
