//
//  WatchView.swift
//  Intervals
//
//  Created by Hunter Whittle on 6/18/15.
//  Copyright © 2015 Hunter Whittle. All rights reserved.
//

import UIKit

class WatchView: UIView {
    
    @IBOutlet weak var bandView: UIView!
    @IBOutlet weak var faceView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let glareView = GlareView(frame: CGRectMake(1.0, 1.0, faceView.frame.size.width, faceView.frame.size.height))
        faceView.addSubview(glareView)
        self.faceView.layer.cornerRadius = 3.0
        
        bandView.layer.cornerRadius = 2.0
        bandView.layer.borderColor = UIColor(white: 0.5, alpha: 1.0).CGColor
        bandView.layer.borderWidth = 0.5
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
