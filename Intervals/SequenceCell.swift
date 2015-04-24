//
//  SequenceCell.swift
//  Intervals
//
//  Created by Hunter Whittle on 4/22/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

import UIKit

protocol SequenceCellDelegate {
    func sequenceCellDidTapInfoButton(cell: SequenceCell)
}

class SequenceCell: UITableViewCell {
    
    @IBOutlet weak var titleLabelLeftSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var watchView: UIView!
    @IBOutlet weak var watchFaceView: UIView!
    @IBOutlet weak var watchBandView: UIView!
    
    var delegate: SequenceCellDelegate! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let glareView = GlareView(frame: CGRectMake(1.0, 1.0, self.watchFaceView.frame.size.width, self.watchFaceView.frame.size.height))
        self.watchFaceView.addSubview(glareView)
        self.watchFaceView.layer.cornerRadius = 3.0
        
        self.watchBandView.layer.cornerRadius = 2.0
        self.watchBandView.layer.borderColor = UIColor(white: 0.5, alpha: 1.0).CGColor
        self.watchBandView.layer.borderWidth = 0.5
        self.watchView.hidden = true
        
        self.infoButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        self.infoButton.layer.cornerRadius = self.infoButton.frame.size.width / 2
        self.infoButton.layer.borderWidth = 0.75
        self.infoButton.layer.borderColor = UIColor(red: 0.0, green: 0.25, blue: 0.95, alpha: 1.0).CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
//        if highlighted {
//            self.backgroundColor = UIColor.redColor()
//        }
    }
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        
        self.delegate.sequenceCellDidTapInfoButton(self)
    }
    
    func loadedOnWatch(loaded: NSNumber) {
        
        if loaded == 1 {
            self.titleLabelLeftSpaceConstraint.constant = 22
            self.watchView.hidden = false
        }
        else {
            self.titleLabelLeftSpaceConstraint.constant = 0
            self.watchView.hidden = true
        }
    }
}
