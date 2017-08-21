//
//  FeedTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import HCSStarRatingView
import FontAwesomeKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var feedImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var ratingsView: HCSStarRatingView!
    @IBOutlet weak var leftQuoteLabel: UILabel!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    
    internal var optionsHandler: ((String?)->Void)?
    internal var feedKey: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.feedBackgroundColor()
        nameLabel.textColor = ThemeManager.sharedInstance.feedTextColor()
        nameLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        commentLabel.textColor = ThemeManager.sharedInstance.feedTextColor()
        commentLabel.font = ThemeManager.sharedInstance.defaultFont(16)
        timeLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        timeLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        let leftQuote = FAKIonIcons.quoteIcon(withSize: 25)
        leftQuote?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.labelTitleColor())
        leftQuoteLabel.attributedText = leftQuote?.attributedString()
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
        
        if let comment = feedItem.comment, comment.characters.count > 0 {
            commentLabel.text = comment
            commentLabel.isHidden = false
            leftQuoteLabel.isHidden = false
            timeLabelTopConstraint.constant = 5
        } else {
            commentLabel.isHidden = true
            leftQuoteLabel.isHidden = true
            timeLabelTopConstraint.constant = -5
        }
        
        let nameText = "\(name) did \(feedItem.breathCount) breaths"
        let boldRange = rangeOfString(name, inString: nameText)
        let attrString = NSMutableAttributedString(string: nameText)
        let stringRange = NSRange(location: 0, length: nameText.characters.count)
        attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: ThemeManager.sharedInstance.feedTextColor(), range: stringRange)
        attrString.addAttribute(NSAttributedStringKey.font, value: ThemeManager.sharedInstance.defaultFont(16), range: stringRange)
         if let boldRange = boldRange {
            attrString.addAttribute(NSAttributedStringKey.font, value: ThemeManager.sharedInstance.heavyFont(16), range: boldRange)
        }
        nameLabel.attributedText = attrString
    }
    
    func rangeOfString(_ substring: String, inString: String) -> NSRange? {
        let cocoaString = NSString(string: inString)
        return cocoaString.range(of: substring)
    }

    @IBAction func onRemoveTap(_ sender: Any) {
        optionsHandler?(feedKey)
    }
}
