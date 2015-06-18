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
    
    var delegate: SequenceCellDelegate! = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.infoButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15.0)
        self.infoButton.layer.cornerRadius = self.infoButton.frame.size.width / 2
        self.infoButton.layer.borderWidth = 0.75
        self.infoButton.layer.borderColor = Colors.intervalsBlue.CGColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        var alpha: CGFloat = 0.25
        if !highlighted {
            
            alpha = 1.0
            
            UIView.animateWithDuration(0.2, animations: ({
                
                self.titleLabel.alpha = alpha
                self.detailLabel.alpha = alpha
                self.infoButton.alpha = alpha
                
            }), completion: { finished in
                
            });
        }
        else {
            self.titleLabel.alpha = alpha
            self.detailLabel.alpha = alpha
            self.infoButton.alpha = alpha
        }
    }
    
    @IBAction func infoButtonTapped(sender: AnyObject) {
        
        self.delegate.sequenceCellDidTapInfoButton(self)
    }
    
    func loadedOnWatch(loaded: NSNumber) {
        
        if loaded == 1 {
            self.titleLabelLeftSpaceConstraint.constant = 30
        }
        else {
            self.titleLabelLeftSpaceConstraint.constant = 8
        }
    }
}
