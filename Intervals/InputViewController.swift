//
//  InputViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData
import WatchCoreDataProxy

class InputViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    let kZeroDelayIndex = 0
    let kThreeDelayIndex = 1
    let kFiveDelayIndex = 2
    let kTenDelayIndex = 3
    
    let cellID = "CellID"
    
    var addBarButton = UIBarButtonItem()
    var cancelBarButton = UIBarButtonItem()
    var editBarButton = UIBarButtonItem()
    var saveBarButton = UIBarButtonItem()
    
    var intervalArray = NSMutableArray()
    
    var sequenceID: NSManagedObjectID = NSManagedObjectID()
    var readOnly: Bool = false
    var editMode: Bool = false
    private var viewsLoaded = false
    
    var nameTextField = UITextField()
    var delaySegControl = UISegmentedControl()
    
    var initialTableInset = UIEdgeInsetsZero
    
    @IBOutlet weak var theTableView: ReorderTableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.theTableView.registerNib(UINib(nibName: "InputCell", bundle: nil), forCellReuseIdentifier: cellID)
        self.theTableView.tableFooterView = UIView()
        
        if self.readOnly == true {
            
            self.title = "Detail"
            
            let sequence = self.getSequence()
            let sort = NSSortDescriptor(key: "position", ascending: true)
            let array = sequence.intervals.sortedArrayUsingDescriptors([sort]) as NSArray
            self.intervalArray = NSMutableArray(array: array)
            
            self.theTableView.reorderEnabled = false
            self.theTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            self.editBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("editButtonTapped"))
            self.navigationItem.rightBarButtonItem = self.editBarButton
            
            self.saveBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("saveButtonTapped"))
        }
        else {
            
            self.title = "New"
            
            self.addBarButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Done, target: self, action: Selector("addButtonTapped"))
            self.navigationItem.rightBarButtonItem = self.addBarButton
            
            self.cancelBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelButtonTapped"))
            self.navigationItem.leftBarButtonItem = self.cancelBarButton
            
            var interval = NSEntityDescription.insertNewObjectForEntityForName("Interval", inManagedObjectContext: self.managedObjectContext) as! HWInterval
            var interval2 = NSEntityDescription.insertNewObjectForEntityForName("Interval", inManagedObjectContext: self.managedObjectContext) as! HWInterval
            interval.title = ""
            interval2.title = ""
            interval.duration = 0
            interval2.duration = 0
            self.intervalArray.addObject(interval)
            self.intervalArray.addObject(interval2)
            self.theTableView.reloadData()
        }
        
        self.theTableView.sourceArray = self.intervalArray
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !viewsLoaded {
            
            initialTableInset = theTableView.contentInset
            
            let headerView = UIView(frame: CGRectMake(0, 0, self.theTableView.frame.size.width, 155))
            headerView.layer.borderColor = UIColor(white: 0.825, alpha: 1.0).CGColor
            headerView.layer.borderWidth = 0.5
            
            nameTextField = UITextField(frame: CGRectMake(15, 10, headerView.frame.size.width - 30, 50))
            nameTextField.borderStyle = UITextBorderStyle.None
            nameTextField.placeholder = "Sequence Name"
            nameTextField.font = UIFont(name: "HelveticaNeue", size: 21.0)
            nameTextField.returnKeyType = UIReturnKeyType.Done
            nameTextField.delegate = self
            headerView.addSubview(self.nameTextField)
            
            let labelX = self.nameTextField.frame.origin.x
            let labelY = self.nameTextField.frame.origin.y + self.nameTextField.frame.size.height + 10
            let label = UILabel(frame: CGRectMake(labelX, labelY, 200, 30))
            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.darkGrayColor()
            label.font = UIFont.systemFontOfSize(15.0)
            label.text = "Time between intervals"
            headerView.addSubview(label)
            
            let segY = label.frame.origin.y + label.frame.size.height + 5
            delaySegControl = UISegmentedControl(items: ["0 sec", "3 sec", "5 sec", "10 sec"])
            delaySegControl.frame = CGRectMake(self.nameTextField.frame.origin.x, segY, self.nameTextField.frame.size.width, 30)
            delaySegControl.selectedSegmentIndex = 0
            headerView.addSubview(delaySegControl)
            
            self.theTableView.tableHeaderView = headerView
            
            if readOnly {
                
                nameTextField.text = getSequence().name
                nameTextField.enabled = false
                delaySegControl.enabled = false
                
                let delay = getSequence().delay.integerValue
                if delay == 0 {
                    delaySegControl.selectedSegmentIndex = 0
                } else if delay == 3 {
                    delaySegControl.selectedSegmentIndex = 1
                } else if delay == 5 {
                    delaySegControl.selectedSegmentIndex = 2
                } else if delay == 10 {
                    delaySegControl.selectedSegmentIndex = 3
                }
            }
            
            viewsLoaded = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.readOnly {
            self.nameTextField.becomeFirstResponder()
        }
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        super.willMoveToParentViewController(parent)
        
        if parent != self.parentViewController {
            self.managedObjectContext.rollback()
        }
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var result = 0
        
        if self.readOnly {
            result = self.editMode ? self.intervalArray.count + 1 : self.intervalArray.count
        }
        else {
            result = self.intervalArray.count + 1
        }
        
        return result
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == self.intervalArray.count {
            
            if !self.readOnly || self.editMode {
                var addCell = tableView.dequeueReusableCellWithIdentifier("Cell") as! UITableViewCell!
                
                if addCell == nil {
                    addCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
                }
                
                addCell.textLabel?.text = "Add Interval"
                addCell.textLabel?.textColor = Colors.intervalsGreen
                
                return addCell
            }
        }
            
        var cell: InputCell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! InputCell
        
        let interval: HWInterval = self.intervalArray[indexPath.row] as! HWInterval
        cell.nameTextField.text = interval.title
        
        let minString = interval.minutes.intValue > 0 ? "\(interval.minutes) min" : ""
        let secString = interval.seconds.intValue > 0 ? "\(interval.seconds) sec" : ""
        if minString == "" && secString == "" {
            cell.durationTextField.text = ""
        }
        else {
            cell.durationTextField.text = "\(minString) \(secString)"
            cell.duration = interval.duration.integerValue
            cell.minutes = interval.minutes.integerValue
            cell.seconds = interval.seconds.integerValue
        }
        
        if self.readOnly {
            cell.userInteractionEnabled = self.editMode
        }

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        if indexPath.row == self.intervalArray.count {
            
            var interval = NSEntityDescription.insertNewObjectForEntityForName("Interval", inManagedObjectContext: self.managedObjectContext) as! HWInterval
            interval.title = ""
            self.intervalArray.addObject(interval)
            
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.intervalArray.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Bottom)
            tableView.endUpdates()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        var result = true
        
        if indexPath.row == self.intervalArray.count {
            
            if !self.readOnly {
                result = false
            }
            else {
                
                if self.editMode {
                    result = false
                }
            }
        }
        
        return result
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        
        var duplicateRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Duplicate", handler:{action, indexpath in
            
            let existingInterval = self.intervalArray.objectAtIndex(indexPath.row) as! HWInterval
            var newInterval = NSEntityDescription.insertNewObjectForEntityForName("Interval", inManagedObjectContext: self.managedObjectContext) as! HWInterval
            
            if existingInterval.objectID.temporaryID {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! InputCell
                newInterval.title = cell.nameTextField.text
                newInterval.duration = cell.duration
                newInterval.minutes = cell.minutes
                newInterval.seconds = cell.seconds
            }
            else {
                newInterval.title = existingInterval.title
                newInterval.duration = existingInterval.duration
                newInterval.minutes = existingInterval.minutes
                newInterval.seconds = existingInterval.seconds
            }

            self.intervalArray.insertObject(newInterval, atIndex: indexPath.row+1)
            
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row+1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Bottom)
            tableView.endUpdates()
            tableView.setEditing(false, animated: true)
        });
        duplicateRowAction.backgroundColor = Colors.intervalsGreen
        
        var deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete", handler:{action, indexpath in
            
            let interval = self.intervalArray.objectAtIndex(indexPath.row) as! HWInterval
            self.managedObjectContext.deleteObject(interval)
            self.intervalArray.removeObjectAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            tableView.endUpdates()
        });
        
        return [deleteRowAction, duplicateRowAction];
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {

    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Private methods
    
    func addButtonTapped() {
    
        self.repositionExistingSequences()
        
        var sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: self.managedObjectContext) as! HWSequence
        sequence.position = 0
        if self.nameTextField.text == nil || self.nameTextField.text == "" {
            sequence.name = "My sequence"
        }
        else {
            sequence.name = self.nameTextField.text
        }
        
        if delaySegControl.selectedSegmentIndex == kZeroDelayIndex {
            sequence.delay = 0
        } else if delaySegControl.selectedSegmentIndex == kThreeDelayIndex {
            sequence.delay = 3
        } else if delaySegControl.selectedSegmentIndex == kFiveDelayIndex {
            sequence.delay = 5
        } else if delaySegControl.selectedSegmentIndex == kTenDelayIndex {
            sequence.delay = 10
        }
        
        var isValid = true
        for var i=0; i<self.intervalArray.count; i++ {
            
            let interval = self.intervalArray[i] as! HWInterval
            let cell: InputCell = self.theTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! InputCell
            
            interval.title = cell.nameTextField.text
            interval.duration = cell.duration
            interval.minutes = cell.minutes
            interval.seconds = cell.seconds
            interval.position = i
            
            if interval.title == "" || interval.duration == 0 {
                self.showInvalidEntryAlert()
                
                self.managedObjectContext.deleteObject(sequence)
                isValid = false
                break
            }
            
            sequence.addIntervalObject(interval)
        }
        
        if isValid {
            var error: NSError?
            self.managedObjectContext.save(&error)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func cancelButtonTapped () {
        
        self.managedObjectContext.rollback()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func editButtonTapped() {
        
        nameTextField.enabled = true
        delaySegControl.enabled = true
        navigationItem.rightBarButtonItem = self.saveBarButton
        editMode = true
        theTableView.reorderEnabled = true
        theTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        theTableView.reloadData()
    }
    
    func saveButtonTapped() {
        
        let validEntries: Bool = self.editIntervals()
        if validEntries {
            
            getSequence().name = self.nameTextField.text
            
            if delaySegControl.selectedSegmentIndex == kZeroDelayIndex {
                getSequence().delay = 0
            } else if delaySegControl.selectedSegmentIndex == kThreeDelayIndex {
                getSequence().delay = 3
            } else if delaySegControl.selectedSegmentIndex == kFiveDelayIndex {
                getSequence().delay = 5
            } else if delaySegControl.selectedSegmentIndex == kTenDelayIndex {
                getSequence().delay = 10
            }
            
            var error: NSError?
            self.managedObjectContext.save(&error)
            
            if self.getSequence().loadedOnWatch == 1 {
                DarwinHelper.postSequenceLoadNotification()
            }
            
            self.navigationController?.popViewControllerAnimated(true)
        } 
    }
    
    func repositionExistingSequences() {
        
        let entityDesc = NSEntityDescription.entityForName("Sequence", inManagedObjectContext: self.managedObjectContext)
        let request: NSFetchRequest = NSFetchRequest()
        request.entity = entityDesc
        
        let sort = NSSortDescriptor(key: "position", ascending: true)
        request.sortDescriptors = [sort]
        
        var anError: NSError?
        let sequenceArray = self.managedObjectContext.executeFetchRequest(request, error: &anError)! as NSArray
        
        for var i=0; i<sequenceArray.count; i++ {
            let storedSequence = sequenceArray[i] as! HWSequence
            storedSequence.position = storedSequence.position.integerValue + 1
        }
    }
    
    func getSequence() -> HWSequence {
        var error: NSError?
        let sequence = self.managedObjectContext.existingObjectWithID(self.sequenceID, error: &error) as! HWSequence
        return sequence
    }
    
    func editIntervals() -> Bool {
        
        for var i=0; i<self.intervalArray.count; i++ {
            
            let interval = self.intervalArray[i] as! HWInterval
            let cell: InputCell = self.theTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as! InputCell
            
            interval.title = cell.nameTextField.text
            interval.duration = cell.duration
            interval.minutes = cell.minutes
            interval.seconds = cell.seconds
            interval.position = i
            
            if interval.title == "" || interval.duration == 0 {
                self.showInvalidEntryAlert()
                return false
            }
            
            if interval.objectID.temporaryID {
                self.getSequence().addIntervalObject(interval)
            }
        }
        
        return true
    }
    
    func showInvalidEntryAlert() {
        let alert = UIAlertView(title: "Missing fields", message: "\nPlease enter a title and duration for each interval", delegate: nil, cancelButtonTitle: "Ok")
        alert.show()
    }
    
    //MARK: Notifications
    
    func keyboardWillShow(notification: NSNotification) {
        
        let cellArray = self.theTableView.visibleCells() as NSArray
        
        for var i=0; i<cellArray.count; i++ {
            
            if let cell = cellArray[i] as? InputCell {
                
                if cell.durationTextField.isFirstResponder() || cell.nameTextField.isFirstResponder() {
                    let indexPath = self.theTableView.indexPathForCell(cell)
                    self.theTableView.contentInset = UIEdgeInsetsMake(0, 0, 275, 0)
                    self.theTableView.scrollToRowAtIndexPath(indexPath!, atScrollPosition: UITableViewScrollPosition.Top, animated: true)
                    break
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        theTableView.contentInset = initialTableInset
    }
}
