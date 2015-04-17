//
//  ViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData

class ViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, UIActionSheetDelegate {

    let kInputSegue = "inputSegue"
    let kDetailSegue = "sequenceDetailSegue"
    
    var sequenceArray = NSMutableArray()
    var selectedSequenceID = NSManagedObjectID()
    
    var snapshot: UIView = UIView()
    var sourceIndexPath: NSIndexPath = NSIndexPath()
    
    @IBOutlet weak var theTableView: ReorderTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Intervals"
        
        let plusBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("plusButtonTapped"))
        self.navigationItem.leftBarButtonItem = plusBarButton
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
                
                let sequence = self.sequenceArray[i] as! Sequence
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell!
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        let sequence = self.sequenceArray[indexPath.row] as! Sequence
        
        cell.textLabel?.text = sequence.name
        
        var detailText = sequence.intervals.count > 1 ? "intervals" : "interval"
        cell.detailTextLabel?.text = "\(sequence.intervals.count) \(detailText)"
        cell.accessoryType = UITableViewCellAccessoryType.DetailButton
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Load on Apple Watch")
        actionSheet.showInView(self.view)
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        
        let sequence = self.sequenceArray[indexPath.row] as! Sequence
        self.selectedSequenceID = sequence.objectID
        self.performSegueWithIdentifier(kDetailSegue, sender: self)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
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

