//
//  ReorderTableView.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/17/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit

class ReorderTableView: UITableView {
    
    var snapshot: UIView = UIView()
    var sourceIndexPath: NSIndexPath?
    
    var sourceArray = NSMutableArray()
    
    var reorderEnabled: Bool = true
    var reordered: Bool = false

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("longPressGesture:"))
        self.addGestureRecognizer(longPress)
    }

    func longPressGesture(sender: AnyObject) {
        
        if reorderEnabled == false {
            return
        }
        
        let longPressGesture = sender as! UILongPressGestureRecognizer
        let state = longPressGesture.state
        
        let location: CGPoint = longPressGesture.locationInView(self)
        var indexPath: NSIndexPath? = self.indexPathForRowAtPoint(location)
        
        if state == UIGestureRecognizerState.Began {
            
            if let sourceIndexPath = indexPath {
                
                self.sourceIndexPath = sourceIndexPath
                
                let cell = self.cellForRowAtIndexPath(sourceIndexPath)
                if cell?.isMemberOfClass(UITableViewCell.classForCoder()) == true {
                    self.sourceIndexPath = nil
                    indexPath = nil
                    return
                }
                
                self.snapshot = self.snapshotFromView(cell!)
                
                var center = cell?.center
                self.snapshot.center = center!
                self.snapshot.alpha = 0.0
                self.addSubview(snapshot)
                UIView.animateWithDuration(0.2, animations: ({
                    
                    center?.y = location.y
                    self.snapshot.center = center!
                    self.snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05)
                    self.snapshot.alpha = 0.98
                    
                    cell!.alpha = 0.0
                    
                }), completion: { finished in
                    cell?.hidden = true
                });
            }
        }
        else if state == UIGestureRecognizerState.Changed {
            
            self.reordered = true
            
            var center = snapshot.center
            center.y = location.y
            self.snapshot.center = center
            
            if let index = indexPath {
                
                if indexPath != self.sourceIndexPath && indexPath?.row < self.sourceArray.count {
                    self.sourceArray.exchangeObjectAtIndex(indexPath!.row, withObjectAtIndex: self.sourceIndexPath!.row)
                    self.moveRowAtIndexPath(self.sourceIndexPath!, toIndexPath: indexPath!)
                    self.sourceIndexPath = indexPath!
                }
            }
        }
        else {
            
            if let sourceIndexPath = self.sourceIndexPath {
                
                let cell = self.cellForRowAtIndexPath(sourceIndexPath)
                cell?.hidden = false
                cell?.alpha = 0.0
                UIView.animateWithDuration(0.2, animations: ({
                    
                    self.snapshot.center = cell!.center;
                    self.snapshot.transform = CGAffineTransformIdentity
                    self.snapshot.alpha = 0.0
                    
                    cell!.alpha = 1.0
                    
                }), completion: { finished in
                    
                    self.sourceIndexPath = nil
                    self.snapshot.removeFromSuperview()
                    self.snapshot = UIView()
                    cell?.hidden = false
                });
            }
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
