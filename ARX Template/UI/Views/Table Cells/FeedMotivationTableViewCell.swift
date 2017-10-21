//
//  FeedMotivationTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 10/20/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class FeedMotivationTableViewCell: UITableViewCell {
    @IBOutlet weak var motivationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        motivationLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        motivationLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        
        FirebaseService.sharedInstance.retrieveMotivationOfTheDay() { [unowned self] quote in
            // was the bird quote 9/3
            self.motivationLabel.text = quote
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
