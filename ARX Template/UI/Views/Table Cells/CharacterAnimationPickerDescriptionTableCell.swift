//
//  CharacterAnimationPickerDescriptionTableCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/11/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

struct CharacterAnimationPickerDescriptionConstants {
    static let CellIdentifier = "CharacterAnimationPickerDescriptionCellIdentifier"
}

class CharacterAnimationPickerDescriptionTableCell: UITableViewCell {

    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packageDescriptionLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        packageNameLabel.textColor = ThemeManager.sharedInstance.textColor()
        packageDescriptionLabel.textColor = ThemeManager.sharedInstance.textColor()
        packageNameLabel.font = ThemeManager.sharedInstance.defaultFont(20)
        packageDescriptionLabel.font = ThemeManager.sharedInstance.defaultFont(16)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
