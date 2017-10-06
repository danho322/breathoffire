//
//  UserStatCollectionCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/3/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

struct UserStatConstants {
    static let CellIdentifier = "UserStatCellIdentifier"
}

class UserStatCollectionCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statLabel: UILabel!

    override func awakeFromNib() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        statLabel.textColor = ThemeManager.sharedInstance.textColor()
        titleLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        statLabel.font = ThemeManager.sharedInstance.heavyFont(18)
        
        let icon = FAKMaterialIcons.fireIcon(withSize: 20)
        icon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.labelTitleColor())
        iconImageView.image = icon?.image(with: CGSize(width: 20, height: 20))
    }
}
