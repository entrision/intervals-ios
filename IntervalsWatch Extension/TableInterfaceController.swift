//
//  TableInterfaceController.swift
//  Intervals
//
//  Created by Hunter Whittle on 6/18/15.
//  Copyright © 2015 Hunter Whittle. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class TableInterfaceController: WKInterfaceController {

    @IBOutlet var table: WKInterfaceTable!
    
    let wcSession = WCSession.defaultSession()
    var sequences = NSArray()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        setTitle("Intervals")
        
        wcSession.delegate = self
        wcSession.activateSession()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        super.table(table, didSelectRowAtIndex: rowIndex)
        
        let selectedSequence = sequences[rowIndex] as! NSDictionary
        pushControllerWithName("TimerController", context: selectedSequence)
    }
}

//MARK: WCSessionDelegate
extension TableInterfaceController : WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        
        sequences = message["sequences"] as! NSArray
        table.setNumberOfRows(sequences.count, withRowType: "SequenceRowController")
        
        var i = 0
        for sequence in sequences {
            
            let theSequence = sequence as! NSDictionary
            let row = table.rowControllerAtIndex(i) as! SequenceRowController
            row.sequenceLabel.setText(theSequence["name"] as? String)
            i++
        }
    }
}
