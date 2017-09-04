//
//  UserStatCollectionCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/3/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

struct UserStatConstants {
    static let CellIdentifier = "UserStatCellIdentifier"
}

class UserStatCollectionCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statLabel: UILabel!

    override func awakeFromNib() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
        backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.textColor()
        statLabel.textColor = ThemeManager.sharedInstance.textColor()
    }
}
