//
//  InputViewController.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData

class InputViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    let cellID = "CellID"
    
    var addBarButton = UIBarButtonItem()
    var intervalArray = NSMutableArray()
    
    @IBOutlet weak var theTableView: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.addBarButton = UIBarButtonItem(title: "Add", style: UIBarButtonItemStyle.Done, target: self, action: Selector("addButtonTapped"))
        self.navigationItem.rightBarButtonItem = self.addBarButton
        
//        let headerView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 70))
//        
//        let nameTextField = UITextField(frame: CGRectMake(15, 15, headerView.frame.size.width - 30, 50))
//        nameTextField.borderStyle = UITextBorderStyle.None
//        nameTextField.placeholder = "Interval Name..."
//        nameTextField.font = UIFont.systemFontOfSize(21.0)
//        headerView.addSubview(nameTextField)
//        
//        self.theTableView.tableHeaderView = headerView
        
        self.theTableView.registerNib(UINib(nibName: "InputCell", bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.intervalArray.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == self.intervalArray.count {
            var addCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell!
            
            if addCell == nil {
                addCell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "Cell")
            }
            
            addCell.textLabel?.text = "Add Interval"
            addCell.textLabel?.textColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
            
            return addCell
        }
            
        var cell: InputCell = tableView.dequeueReusableCellWithIdentifier(cellID, forIndexPath: indexPath) as InputCell
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
        if indexPath.row == self.intervalArray.count {
            
            var interval = NSEntityDescription.insertNewObjectForEntityForName("Interval", inManagedObjectContext: self.managedObjectContext) as Interval
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
            result = false
        }
        
        return result
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
//            self.numOfRows--
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
            tableView.endUpdates()
        }
    }
    
    //MARK: Private methods
    
    func addButtonTapped() {
        
        var sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: self.managedObjectContext) as Sequence
        
        for var i=0; i<self.intervalArray.count; i++ {
            
            let interval = self.intervalArray[i] as Interval
            let cell: InputCell = self.theTableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as InputCell
            
            interval.title = cell.nameTextField.text
            interval.duration = cell.durationTextField.text.toInt()!
            sequence.addIntervalObject(interval)
        }
        
        var error: NSError?
        self.managedObjectContext.save(&error)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
