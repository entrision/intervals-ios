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
        
        self.watchBandView.layer.cornerRadius = 2.0
        self.watchBandView.layer.borderColor = UIColor(white: 0.5, alpha: 1.0).CGColor
        self.watchBandView.layer.borderWidth = 0.5
        self.watchView.hidden = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        
        self.delegate.sequenceCellDidTapInfoButton(self)
    }
    
    func loadedOnWatch(loaded: NSNumber) {
        
        if loaded == 1 {
            self.titleLabelLeftSpaceConstraint.constant = 20
            self.watchView.hidden = false
        }
        else {
            self.titleLabelLeftSpaceConstraint.constant = 0
            self.watchView.hidden = true
        }
    }
}
