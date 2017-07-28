//
//  OptionsTechniquesTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class OptionsTechniquesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
