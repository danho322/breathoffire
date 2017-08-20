//
//  FeedTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import HCSStarRatingView

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ratingsView: HCSStarRatingView!
    
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
        
        if let rating = feedItem.rating {
            ratingsView.isHidden = false
            ratingsView.value = CGFloat(rating)
        } else {
            ratingsView.isHidden = true
        }
        
        let nameText = "\(name) did \(feedItem.breathCount) breaths"
        nameLabel.text = nameText
        
        let now = Date().timeIntervalSince1970
        let diffTime = Int(now) - Int(feedItem.timestamp)
        var timeString = TimeFormatType.feed.timeString(diffTime)
        if let city = feedItem.city {
            timeString.append(" in \(city)")
        }
        timeLabel.text = timeString
        FirebaseService.sharedInstance.retrieveImageAtPath(path: feedItem.imagePath, completion: { image in
            self.feedImageView.image = image
        })
        
    }

    @IBAction func onRemoveTap(_ sender: Any) {
        optionsHandler?(feedKey)
    }
}
