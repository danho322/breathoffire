//
//  FeedTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    internal var optionsHandler: ((String?)->Void)?
    internal var feedKey: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        nameLabel.textColor = ThemeManager.sharedInstance.textColor()
        nameLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        timeLabel.textColor = ThemeManager.sharedInstance.textColor()
        timeLabel.font = ThemeManager.sharedInstance.defaultFont(16)
    }

    func update(feedItem: BreathFeedItem, optionsHandler: @escaping ((String?)->Void)) {
        feedKey = feedItem.key
        self.optionsHandler = optionsHandler

        var name = feedItem.userName
        if name.characters.count == 0 {
            name = "Anonymous"
        }
        nameLabel.text = "\(name) did \(feedItem.breathCount) breaths"
        
        let now = Date().timeIntervalSince1970
        let diffTime = Int(now) - Int(feedItem.timestamp)
        timeLabel.text = TimeFormatType.feed.timeString(diffTime)

        FirebaseService.sharedInstance.retrieveImageAtPath(path: feedItem.imagePath, completion: { image in
            self.feedImageView.image = image
        })
        
    }

    @IBAction func onRemoveTap(_ sender: Any) {
        optionsHandler?(feedKey)
    }
}
