//
//  OptionsMOTDTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/21/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

class OptionsMOTDTableViewCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moveTitleLabel: UILabel!
    @IBOutlet weak var moveDescriptionLabel: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        moveTitleLabel.textColor = ThemeManager.sharedInstance.textColor()
        moveDescriptionLabel.textColor = ThemeManager.sharedInstance.textColor()
        
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        moveTitleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        moveDescriptionLabel.font = ThemeManager.sharedInstance.defaultFont(16)
    
        let chevronIcon = FAKIonIcons.chevronRightIcon(withSize: 20)
        chevronIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        loadButton.setAttributedTitle(chevronIcon?.attributedString(), for: .normal)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
