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
    
    @IBOutlet weak var theTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "Intervals"
        
        let plusBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("plusButtonTapped"))
        self.navigationItem.leftBarButtonItem = plusBarButton
        
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longPressGesture:"))
        self.theTableView.addGestureRecognizer(longPress)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.fetchSequences()
        self.theTableView.reloadData()
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

        var error: NSError?
        let array = self.managedObjectContext.executeFetchRequest(request, error: &error)
        self.sequenceArray = NSMutableArray(array: array!)
    }
    
    func longPressGesture(sender: AnyObject) {
        
        let longPressGesture = sender as! UILongPressGestureRecognizer
        let state = longPressGesture.state
        
        let location: CGPoint = longPressGesture.locationInView(self.theTableView)
        let indexPath: NSIndexPath = self.theTableView.indexPathForRowAtPoint(location)!
        
        if state == UIGestureRecognizerState.Began {
            
            self.sourceIndexPath = indexPath
            
            let cell = self.theTableView.cellForRowAtIndexPath(indexPath)
            self.snapshot = self.snapshotFromView(cell!)
            
            var center = cell?.center
            self.snapshot.center = center!
            self.snapshot.alpha = 0.0
            self.theTableView.addSubview(snapshot)
            UIView.animateWithDuration(0.25, animations: ({
                
                center?.y = location.y
                self.snapshot.center = center!
                self.snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
                self.snapshot.alpha = 0.98
                
                cell!.alpha = 0.0
                
            }), completion: { finished in
                cell?.hidden = true
            });
            
        }
        else if state == UIGestureRecognizerState.Changed {
            
            var center = snapshot.center
            center.y = location.y
            self.snapshot.center = center
        
            if indexPath != self.sourceIndexPath {
                self.sequenceArray.exchangeObjectAtIndex(indexPath.row, withObjectAtIndex: self.sourceIndexPath.row)
                self.theTableView.moveRowAtIndexPath(self.sourceIndexPath, toIndexPath: indexPath)
                sourceIndexPath = indexPath
            }
        }
        else {
            
            let cell = self.theTableView.cellForRowAtIndexPath(self.sourceIndexPath)
            cell?.hidden = false
            cell?.alpha = 0.0
            UIView.animateWithDuration(0.25, animations: ({
                
                self.snapshot.center = cell!.center;
                self.snapshot.transform = CGAffineTransformIdentity
                self.snapshot.alpha = 0.0
                
                cell!.alpha = 1.0
                
            }), completion: { finished in
                
                self.sourceIndexPath = NSIndexPath()
                self.snapshot.removeFromSuperview()
                self.snapshot = UIView()
            });
        }
    }
    
    func snapshotFromView(view: UIView) -> UIView {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext())
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.cornerRadius = 0.0
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.4
        
        return snapshot
    }
}

