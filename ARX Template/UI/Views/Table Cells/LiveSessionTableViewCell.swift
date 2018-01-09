//
//  LiveSessionTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 1/8/18.
//  Copyright © 2018 Daniel Ho. All rights reserved.
//

import UIKit

class LiveSessionTableViewCell: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var intentionLabel: UILabel!
    @IBOutlet weak var joinLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        backgroundColor = UIColor.clear
        nameLabel.textColor = ThemeManager.sharedInstance.textColor()
        timeLabel.textColor = ThemeManager.sharedInstance.textColor()
        intentionLabel.textColor = ThemeManager.sharedInstance.textColor()
        joinLabel.textColor = ThemeManager.sharedInstance.focusColor()
        
        nameLabel.font = ThemeManager.sharedInstance.heavyFont(18)
        timeLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        intentionLabel.font = ThemeManager.sharedInstance.defaultFont(16)
        joinLabel.font = ThemeManager.sharedInstance.heavyFont(18)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(_ session: LiveSession) {
        intentionLabel.text = session.intention
        
        var nameText = "\(session.userName) is breathing"
        if session.intention.count > 0 {
            nameText.append(" to")
        }
        nameLabel.text = nameText
        let now = Date().timeIntervalSince1970
        let diffTime = Int(now) - Int(session.startTimestamp)
        timeLabel.text = "Started \(TimeFormatType.feed.timeString(diffTime))"
        
        var joinText = "Join"
        if session.userCount > 1 {
            joinText.append("\n\(session.userCount) users")
        }
        joinLabel.text = joinText
    }
}
