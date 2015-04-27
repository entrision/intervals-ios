//
//  AppDelegate.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/14/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit
import CoreData
import WatchCoreDataProxy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.window?.tintColor = UIColor(red: 0.0, green: 0.25, blue: 0.95, alpha: 1.0)
        
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName : UIFont(name: "HelveticaNeue-Light", size: 18.0)!, NSForegroundColorAttributeName : UIColor.blackColor()]
        UINavigationBar.appearance().barTintColor = UIColor(white: 0.925, alpha: 1.0)
        
        if NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce") == true {
            
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            if let managedObjectContext = WatchCoreDataProxy.sharedInstance.managedObjectContext {
                
                var sequence = NSEntityDescription.insertNewObjectForEntityForName("Sequence", inManagedObjectContext: managedObjectContext) as! HWSequence
                sequence.position = 0
                sequence.name = "Example Sequence"
                
                var interval = NSEntityDescription.insertNewObjectForEntityForName("Interval", inManagedObjectContext: managedObjectContext) as! HWInterval
                var interval2 = NSEntityDescription.insertNewObjectForEntityForName("Interval", inManagedObjectContext: managedObjectContext) as! HWInterval
                interval.title = "Interval 1"
                interval2.title = "Interval 2"
                interval.minutes = 0
                interval2.minutes = 0
                interval.seconds = 30
                interval2.seconds = 60
                interval.position = 0
                interval2.position = 1
                interval.duration = 30
                interval2.duration = 60
                
                sequence.addIntervalObject(interval)
                sequence.addIntervalObject(interval2)
                
                var error: NSError?
                managedObjectContext.save(&error)
            }
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        WatchCoreDataProxy.sharedInstance.saveContext()
    }

}

