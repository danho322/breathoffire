//
//  RankingTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 10/5/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var rankingBGView: UIView!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var rankingDescriptionLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        backgroundColor = UIColor.clear
        rankingBGView.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        rankingLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        userNameLabel.textColor = ThemeManager.sharedInstance.textColor()
        locationLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        rankingDescriptionLabel.textColor = ThemeManager.sharedInstance.textColor()
        
        rankingLabel.font = ThemeManager.sharedInstance.heavyFont(30)
        userNameLabel.font = ThemeManager.sharedInstance.heavyFont(18)
        locationLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        rankingDescriptionLabel.font = ThemeManager.sharedInstance.defaultFont(16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
