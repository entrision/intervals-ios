//
//  WatchFaceView.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/22/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit

class GlareView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    func setup() {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 2.0
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.clearColor()
    }

    override func drawRect(rect: CGRect) {
        
        let ctx = UIGraphicsGetCurrentContext()
        
        let inset: CGFloat = 2.5
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));  // top left
        CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect)-inset, CGRectGetMinY(rect));  // far right
        CGContextAddLineToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect)-inset);  // bottom left
        CGContextClosePath(ctx);
        
        CGContextSetRGBFillColor(ctx, 1, 1, 1, 0.7);
        CGContextFillPath(ctx);
    }
}
