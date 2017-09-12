//
//  UserPackagesCollectionCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/11/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import iCarousel

struct UserPackageCellConstants {
    static let CellIdentifier = "UserPackagesCellIdentifier"
}
class UserPackagesCollectionCell: UICollectionViewCell {
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var titleLabel: UILabel!
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        titleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
    }
}
