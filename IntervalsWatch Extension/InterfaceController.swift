//
//  InterfaceController.swift
//  IntervalsWatch Extension
//
//  Created by Hunter Whittle on 6/11/15.
//  Copyright © 2015 Hunter Whittle. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet var sequenceNameLabel: WKInterfaceLabel!
    @IBOutlet var intervalNameLabel: WKInterfaceLabel!
    @IBOutlet var progressLabel: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var actionButton: WKInterfaceButton!
    
    let wcSession = WCSession.defaultSession()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
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
}

//MARK: WCSessionDelegate
extension InterfaceController : WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        var x = 0
        x++
    }
}
