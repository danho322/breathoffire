//
//  OptionsPackageTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/23/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SDWebImage
import FontAwesomeKit

class OptionsPackageTableViewCell: UITableViewCell {
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packageDescriptionLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var techniqueCountTagLabel: UILabel!
    @IBOutlet weak var difficultyTagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        bgImageView.sd_setImage(with: URL(string: "http://graciescottsdale.com/wp-scottsdale/uploads/2014/01/Helio-Flying-680x307.jpg"))
        
        packageNameLabel.textColor = ThemeManager.sharedInstance.textColor()
        packageNameLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        
        packageDescriptionLabel.textColor = ThemeManager.sharedInstance.textColor()
        packageDescriptionLabel.font = ThemeManager.sharedInstance.heavyFont(18)
        
        techniqueCountTagLabel.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        techniqueCountTagLabel.textColor = ThemeManager.sharedInstance.textColor()
        techniqueCountTagLabel.font = ThemeManager.sharedInstance.heavyFont(12)
        difficultyTagLabel.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        difficultyTagLabel.textColor = ThemeManager.sharedInstance.textColor()
        difficultyTagLabel.font = ThemeManager.sharedInstance.heavyFont(12)
        
        let chevronIcon = FAKIonIcons.chevronRightIcon(withSize: 20)
        chevronIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        chevronButton.setAttributedTitle(chevronIcon?.attributedString(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
