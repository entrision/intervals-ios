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

    let kInputSegue = "inputSegue"
    let kDetailSegue = "sequenceDetailSegue"
    let cellID = "CellID"
    
    var sequenceArray = NSMutableArray()
    var selectedSequenceID = NSManagedObjectID()
    
    var snapshot: UIView = UIView()
    var sourceIndexPath: NSIndexPath = NSIndexPath()
    
    @IBOutlet weak var theTableView: ReorderTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Intervals"
        self.navigationController?.navigationBar.barTintColor = UIColor(white: 0.925, alpha: 1.0)
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 18.0)!, NSForegroundColorAttributeName : UIColor.blackColor()]
        
        let plusBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("plusButtonTapped"))
        self.navigationItem.leftBarButtonItem = plusBarButton
        
        self.theTableView.registerNib(UINib(nibName: "SequenceCell", bundle: nil), forCellReuseIdentifier: cellID)
        self.theTableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchSequences()
        self.theTableView.sourceArray = self.sequenceArray
        self.theTableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.theTableView.reordered {
            for var i=0; i<self.sequenceArray.count; i++ {
                
                let sequence = self.sequenceArray[i] as! HWSequence
                sequence.position = i
                
                var error: NSError?
                self.managedObjectContext.save(&error)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == kInputSegue {
            
            let controller: UINavigationController = segue.destinationViewController as! UINavigationController
            controller.transitioningDelegate = self
        }
        else if segue.identifier == kDetailSegue {
            
            let detailController: InputViewController = segue.destinationViewController as! InputViewController
            detailController.sequenceID = self.selectedSequenceID
            detailController.readOnly = true
        }
    }
    
    //MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sequenceArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: SequenceCell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! SequenceCell
        
        let sequence = self.sequenceArray[indexPath.row] as! HWSequence
        
        cell.titleLabel?.text = sequence.name
        
        var detailText = sequence.intervals.count > 1 ? "intervals" : "interval"
        cell.detailLabel?.text = "\(sequence.intervals.count) \(detailText)"
        cell.loadedOnWatch(sequence.loadedOnWatch)
        cell.delegate = self
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        for var i=0; i<self.sequenceArray.count; i++ {
            
            let aSequence = self.sequenceArray[i] as! HWSequence
            if aSequence.loadedOnWatch == 1 {
                aSequence.loadedOnWatch = 0
                break
            }
        }
        
        let sequence = self.sequenceArray[indexPath.row] as! HWSequence
        sequence.loadedOnWatch = 1
        
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Load on Apple Watch")
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
            self.managedObjectContext.deleteObject(sequence)
            self.sequenceArray.removeObjectAtIndex(indexPath.row)
            
            var error: NSError?
            self.managedObjectContext.save(&error)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            tableView.endUpdates()
        }
    }
    
    //MARK: SequenceCellDelegate
    
    func sequenceCellDidTapInfoButton(cell: SequenceCell) {
        
        let indexPath = self.theTableView.indexPathForCell(cell)
        let sequence = self.sequenceArray[indexPath!.row] as! HWSequence
        self.selectedSequenceID = sequence.objectID
        self.performSegueWithIdentifier(kDetailSegue, sender: self)
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
        
        if buttonIndex == 1 {
            
            var error: NSError?
            self.managedObjectContext.save(&error)
            
            if error != nil {
                println(error?.localizedDescription)
            }
            else {
                self.theTableView.reloadData()
                DarwinHelper.postSequenceLoadNotification()
            }
        }
        else {
            self.managedObjectContext.rollback()
        }
    }
    
    //MARK: Private methods
    
    func plusButtonTapped() {
        
        self.performSegueWithIdentifier(kInputSegue, sender: self)
    }
    
    func fetchSequences() {

        let entityDesc = NSEntityDescription.entityForName("Sequence", inManagedObjectContext: self.managedObjectContext)
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entityDesc
        
        let sort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [sort]

        var error: NSError?
        let array = self.managedObjectContext.executeFetchRequest(request, error: &error)
        self.sequenceArray = NSMutableArray(array: array!)
    }
}

