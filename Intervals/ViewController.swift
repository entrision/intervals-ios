//
//  ViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData
import WatchCoreDataProxy

class ViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIActionSheetDelegate, SequenceCellDelegate {

    let kLoadOnWatchButtonIndex: NSInteger = 1
    let kLoadOnPhoneButtonIndex: NSInteger = 2
    
    let kInputSegue = "inputSegue"
    let kDetailSegue = "sequenceDetailSegue"
    let kTimerSegue = "timerSegue"
    let cellID = "CellID"
    
    var sequenceArray = NSMutableArray()
    var selectedSequenceID = NSManagedObjectID()
    
    var snapshot: UIView = UIView()
    var sourceIndexPath: NSIndexPath = NSIndexPath()
    
    @IBOutlet weak var noSequencesLabel: UILabel!
    @IBOutlet weak var theTableView: ReorderTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Intervals"
        
        let plusBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("plusButtonTapped"))
        navigationItem.rightBarButtonItem = plusBarButton
        
        theTableView.registerNib(UINib(nibName: "SequenceCell", bundle: nil), forCellReuseIdentifier: cellID)
        theTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        fetchSequences()
        theTableView.sourceArray = sequenceArray
        theTableView.reloadData()
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
    
    //MARK: UITableViewDataSource

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
        cell.loadedOnWatch(sequence.loadedOnWatch)
        cell.delegate = self
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let sequence = sequenceArray[indexPath.row] as! HWSequence
        selectedSequenceID = sequence.objectID
        
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Load on Apple Watch", "Load on iPhone")
        actionSheet.showInView(self.view)
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
    
    //MARK: SequenceCellDelegate
    
    func sequenceCellDidTapInfoButton(cell: SequenceCell) {
        
        let indexPath = theTableView.indexPathForCell(cell)
        let sequence = sequenceArray[indexPath!.row] as! HWSequence
        selectedSequenceID = sequence.objectID
        performSegueWithIdentifier(kDetailSegue, sender: self)
    }
    
    //MARK: Transitioning Delegate
    
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
    
    //MARK: UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        
        if buttonIndex == kLoadOnWatchButtonIndex {
            
            for var i=0; i<sequenceArray.count; i++ {
                
                let aSequence = sequenceArray[i] as! HWSequence
                if aSequence.loadedOnWatch == 1 {
                    aSequence.loadedOnWatch = 0
                    break
                }
            }
            
            do {
                let selectedSequence = try managedObjectContext.existingObjectWithID(self.selectedSequenceID) as! HWSequence
                selectedSequence.loadedOnWatch = 1
                try managedObjectContext.save()
                
                theTableView.reloadData()
                DarwinHelper.postSequenceLoadNotification()
            } catch {
                print(error)
            }
        }
        else if buttonIndex == kLoadOnPhoneButtonIndex {
            performSegueWithIdentifier(kTimerSegue, sender: self)
        }
        else {
            managedObjectContext.rollback()
        }
    }
    
    //MARK: Private methods
    
    func plusButtonTapped() {
        
        performSegueWithIdentifier(kInputSegue, sender: self)
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
}

