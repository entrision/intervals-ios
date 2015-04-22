//
//  WatchFaceView.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/22/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit

class WatchFaceView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 3.0
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 0.5
    }

    override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let inset: CGFloat = 1.25
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint   (ctx, CGRectGetMinX(rect)+inset, CGRectGetMinY(rect)+inset);  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)-inset, CGRectGetMinY(rect)+inset);  // mid right
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect)+inset, CGRectGetMaxY(rect)-inset);  // bottom left
        CGContextClosePath(ctx);
        
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.8);
        CGContextFillPath(ctx);
    }
}
