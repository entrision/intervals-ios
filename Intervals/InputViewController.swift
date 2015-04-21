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

    let cellID = "CellID"
    
    var addBarButton = UIBarButtonItem()
    var cancelBarButton = UIBarButtonItem()
    var editBarButton = UIBarButtonItem()
    var saveBarButton = UIBarButtonItem()
    
    var intervalArray = NSMutableArray()
    
    var sequenceID: NSManagedObjectID = NSManagedObjectID()
    var readOnly: Bool = false
    var editMode: Bool = false
    
    var nameTextField = UITextField()
    
    @IBOutlet weak var theTableView: ReorderTableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 70))
        headerView.layer.borderColor = UIColor(white: 0.825, alpha: 1.0).CGColor
        headerView.layer.borderWidth = 0.5
        
        self.nameTextField = UITextField(frame: CGRectMake(15, 10, headerView.frame.size.width - 30, 50))
        self.nameTextField.borderStyle = UITextBorderStyle.None
        self.nameTextField.placeholder = "Sequence Name..."
        self.nameTextField.font = UIFont.systemFontOfSize(21.0)
        self.nameTextField.returnKeyType = UIReturnKeyType.Done
        self.nameTextField.delegate = self
        headerView.addSubview(self.nameTextField)
        
        self.theTableView.tableHeaderView = headerView
        self.theTableView.registerNib(UINib(nibName: "InputCell", bundle: nil), forCellReuseIdentifier: cellID)
        self.theTableView.tableFooterView = UIView()
        
        if self.readOnly == true {
            
            let sequence = self.getSequence()
            let sort = NSSortDescriptor(key: "position", ascending: true)
            let array = sequence.intervals.sortedArrayUsingDescriptors([sort]) as NSArray
            self.intervalArray = NSMutableArray(array: array)
            
            self.theTableView.reorderEnabled = false
            self.theTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            self.nameTextField.text = sequence.name
            self.nameTextField.enabled = false
            
            self.editBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("editButtonTapped"))
            self.navigationItem.rightBarButtonItem = self.editBarButton
            
            self.saveBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: Selector("saveButtonTapped"))
        }
        else {
            
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.readOnly {
            self.nameTextField.becomeFirstResponder()
        }
    }
    
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
                addCell.textLabel?.textColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
                
                return addCell
            }
        }
            
        var cell: InputCell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as! InputCell
        
        if self.readOnly {
            
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
            
            cell.userInteractionEnabled = self.editMode
        }

        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
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
        
        if indexPath.row == self.intervalArray.count && !self.readOnly {
            result = false
        }
        
        return result
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            let interval = self.intervalArray.objectAtIndex(indexPath.row) as! HWInterval
            self.managedObjectContext.deleteObject(interval)
            self.intervalArray.removeObjectAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            tableView.endUpdates()
        }
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
        
        self.nameTextField.enabled = true
        self.navigationItem.rightBarButtonItem = self.saveBarButton
        self.editMode = true
        self.theTableView.reorderEnabled = true
        self.theTableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        self.theTableView.reloadData()
    }
    
    func saveButtonTapped() {
        
        let validEntries: Bool = self.editIntervals()
        if validEntries {
            
            self.nameTextField.enabled = false
            self.view.endEditing(true)
            self.navigationItem.rightBarButtonItem = self.editBarButton
            self.editMode = false
            self.theTableView.reorderEnabled = false
            self.theTableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            self.getSequence().name = self.nameTextField.text
            
            var error: NSError?
            self.managedObjectContext.save(&error)
            
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
}
