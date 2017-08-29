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
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var bgDimView: UIView!
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var packageDescriptionLabel: UILabel!
    @IBOutlet weak var chevronButton: UIButton!
    @IBOutlet weak var techniqueCountTagLabel: UILabel!
    @IBOutlet weak var difficultyTagLabel: UILabel!
    @IBOutlet weak var lockIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        cardView.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        
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
    
    func update(package: AnimationPackage) {
        packageNameLabel.text = package.packageName
        packageDescriptionLabel.text = package.packageDescription
        FirebaseService.sharedInstance.retrieveImageAtPath(path: package.imageBGPath) { image in
            self.bgImageView.image = image
        }
        
        let techniques = DataLoader.sharedInstance.sequencesInPackage(packageName: package.packageName)
        techniqueCountTagLabel.text = "\(techniques.count) TECHNIQUES"
        
        var alpha: CGFloat = 0.8
        let hasPackage =
        SessionManager.sharedInstance.hasPackage(packageName: package.packageName)
        var icon = FAKIonIcons.lockedIcon(withSize: 20)
        if hasPackage {
            alpha = 0.4
            icon = FAKIonIcons.unlockedIcon(withSize: 20)
        }
        icon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        lockIcon.image = icon?.image(with: CGSize(width: 20, height: 20))
        bgDimView.alpha = alpha
    }

}
