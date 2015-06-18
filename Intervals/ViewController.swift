//
//  ViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData
import WatchConnectivity

class ViewController: BaseViewController {

    let kLoadOnWatchButtonIndex: NSInteger = 1
    let kLoadOnPhoneButtonIndex: NSInteger = 2
    
    let kInputSegue = "inputSegue"
    let kDetailSegue = "sequenceDetailSegue"
    let kTimerSegue = "timerSegue"
    let cellID = "CellID"
    
    let wcSession = WCSession.defaultSession()
    
    var sequenceArray = NSMutableArray()
    var selectedSequenceID = NSManagedObjectID()
    
    var snapshot: UIView = UIView()
    var sourceIndexPath: NSIndexPath = NSIndexPath()
    
    var watchPaired = false
    
    @IBOutlet weak var noSequencesLabel: UILabel!
    @IBOutlet weak var theTableView: ReorderTableView!
    @IBOutlet weak var watchView: WatchView!
    
    //MARK: Overridden methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Intervals"
        
        let plusBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("plusButtonTapped"))
        navigationItem.rightBarButtonItem = plusBarButton
        
        theTableView.registerNib(UINib(nibName: "SequenceCell", bundle: nil), forCellReuseIdentifier: cellID)
        theTableView.tableFooterView = UIView()
        
        wcSession.delegate = self
        wcSession.activateSession()
        watchPaired = WCSession.defaultSession().paired
        
        if watchPaired {
            let gr = UITapGestureRecognizer(target: self, action: Selector("watchViewTapped"))
            gr.numberOfTapsRequired = 1
            watchView.addGestureRecognizer(gr)
        }
        
        watchView.hidden = !watchPaired
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        fetchSequences()
        theTableView.sourceArray = sequenceArray
        theTableView.reloadData()
        
        if watchPaired {
            sendSequencesToWatch()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if theTableView.reordered {
            for var i=0; i<sequenceArray.count; i++ {
                
                let sequence = sequenceArray[i] as! HWSequence
                sequence.position = i
                
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == kInputSegue {
            
            let controller = segue.destinationViewController as! UINavigationController
            controller.transitioningDelegate = self
        }
        else if segue.identifier == kDetailSegue {
            
            let detailController = segue.destinationViewController as! InputViewController
            detailController.sequenceID = selectedSequenceID
            detailController.readOnly = true
        }
        else if segue.identifier == kTimerSegue {
            
            let timerController = segue.destinationViewController as! TimerViewController
            timerController.sequenceID = selectedSequenceID
        }
    }
    
    //MARK: Private methods
    
    func plusButtonTapped() {
        
        performSegueWithIdentifier(kInputSegue, sender: self)
    }
    
    func watchViewTapped() {
        
        sendSequencesToWatch()
    }
    
    func fetchSequences() {

        let entityDesc = NSEntityDescription.entityForName("Sequence", inManagedObjectContext: self.managedObjectContext)
        let request = NSFetchRequest()
        request.entity = entityDesc
        
        let sort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [sort]

        let array: [AnyObject]?
        do {
            array = try managedObjectContext.executeFetchRequest(request)
        } catch  {
            print(error)
            array = nil
        }
        sequenceArray = NSMutableArray(array: array!)
    }
    
    func sendSequencesToWatch() {
        
        let sequenceDicts = NSMutableArray()
        for aSequence in sequenceArray {
            
            let theSequence = aSequence as! HWSequence
            let attributeDict = theSequence.entity.attributesByName as NSDictionary
            let keys: [String] = attributeDict.allKeys as NSArray as! [String]
            let sequenceDict = theSequence.dictionaryWithValuesForKeys(keys)
            let mutableSequenceDict = NSMutableDictionary(dictionary: sequenceDict)
            
            let sort = NSSortDescriptor(key: "position", ascending: true)
            let sortedIntervals = theSequence.intervals.sortedArrayUsingDescriptors([sort])
            let intervals = NSMutableArray()
            for anInterval in sortedIntervals {
                let theInterval = anInterval as! HWInterval
                let attributes = theInterval.entity.attributesByName as NSDictionary
                let intervalKeys: [String] = attributes.allKeys as NSArray as! [String]
                let intervalDict = theInterval.dictionaryWithValuesForKeys(intervalKeys)
                intervals.addObject(intervalDict)
                mutableSequenceDict.setObject(intervals, forKey: "intervals")
            }

            sequenceDicts.addObject(mutableSequenceDict)
        }
        
        wcSession.sendMessage(["sequences" : sequenceDicts], replyHandler: nil) { (error) -> Void in
            print(error)
        }
    }
}

//MARK: UITableViewDataSource
extension ViewController : UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        noSequencesLabel.hidden = self.sequenceArray.count > 0
        return sequenceArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! SequenceCell
        
        let sequence = sequenceArray[indexPath.row] as! HWSequence
        
        cell.titleLabel?.text = sequence.name
        
        let detailText = sequence.intervals.count > 1 ? "intervals" : "interval"
        cell.detailLabel?.text = "\(sequence.intervals.count) \(detailText)"
//        cell.loadedOnWatch(sequence.loadedOnWatch)
        cell.delegate = self
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
}

//MARK: UITableViewDelegate
extension ViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let sequence = sequenceArray[indexPath.row] as! HWSequence
        selectedSequenceID = sequence.objectID
        performSegueWithIdentifier(kTimerSegue, sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let sequence = self.sequenceArray.objectAtIndex(indexPath.row) as! HWSequence
            managedObjectContext.deleteObject(sequence)
            sequenceArray.removeObjectAtIndex(indexPath.row)
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            tableView.endUpdates()
        }
    }
}

//MARK: SequenceCellDelegate
extension ViewController : SequenceCellDelegate {
    
    func sequenceCellDidTapInfoButton(cell: SequenceCell) {
        
        let indexPath = theTableView.indexPathForCell(cell)
        let sequence = sequenceArray[indexPath!.row] as! HWSequence
        selectedSequenceID = sequence.objectID
        performSegueWithIdentifier(kDetailSegue, sender: self)
    }
}

//MARK: Transitioning Delegate
extension ViewController : UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let transition = CustomModalTransition()
        transition.presenting = true
        return transition
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let transition = CustomModalTransition()
        transition.presenting = false
        return transition
    }
}

//MARK: WCSessionDelegate
extension ViewController : WCSessionDelegate {
    
    
}
