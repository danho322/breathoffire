//
//  TechniqueTableCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/3/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class TechniqueTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.textColor()
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        descriptionLabel.textColor = ThemeManager.sharedInstance.textColor()
        descriptionLabel.font = ThemeManager.sharedInstance.defaultFont(16)
        durationLabel.textColor = ThemeManager.sharedInstance.textColor()
        durationLabel.font = ThemeManager.sharedInstance.defaultFont(16)
    }

    func update(with sequenceName: String) {
        titleLabel.text = sequenceName
        if let sequenceData = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName) {
            descriptionLabel.text = sequenceData.sequenceDescription
            let sequenceDuration = sequenceData.sequenceDuration()
            let sequenceDurationString = ARXUtilities.durationString(sequenceDuration)
            durationLabel.text = "Session time: \(sequenceDurationString)"
        }
    }

    class func cellSize(sequenceName: String) -> CGFloat {
        var height: CGFloat = 60
        if let sequenceData = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName) {
            let descriptionText = sequenceData.sequenceDescription
            height += ARXUtilities.heightFor(descriptionText, width: Sizes.ScreenWidth - 30, font: ThemeManager.sharedInstance.defaultFont(16))
        }
        return height
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        backgroundColor = selected ?
            ThemeManager.sharedInstance.foregroundColor() :
            ThemeManager.sharedInstance.backgroundColor()
    }
}
