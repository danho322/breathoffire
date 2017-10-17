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
import SDWebImage

class FeedTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var feedImageView: FLAnimatedImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var leftQuoteLabel: UILabel!
    @IBOutlet weak var timeLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playButton: UIButton!
    
    internal var optionsHandler: ((String?)->Void)?
    internal var feedKey: String?
    internal var gifDict: [String: FLAnimatedImage] = Dictionary<String, FLAnimatedImage>()
    internal var gifCreation: (()->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.feedBackgroundColor()
        nameLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        nameLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        commentLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        commentLabel.font = ThemeManager.sharedInstance.defaultFont(16)
        timeLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        timeLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        
        let playIcon = FAKMaterialIcons.playCircleIcon(withSize: 40)
        playIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        playButton.setAttributedTitle(playIcon?.attributedString(), for: .normal)
        
        let leftQuote = FAKIonIcons.quoteIcon(withSize: 12)
        leftQuote?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
        leftQuoteLabel.attributedText = leftQuote?.attributedString()
        
        moreButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        moreButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(16)
    }

    func update(feedItem: BreathFeedItem, optionsHandler: @escaping ((String?)->Void)) {
        guard let feedKey = feedItem.key else {
            return
        }
        self.playButton.isHidden = false
        self.gifCreation = nil
        self.feedKey = feedItem.key
        self.optionsHandler = optionsHandler

        var name = feedItem.userName
        if name.characters.count == 0 {
            name = "Anonymous"
        }
        
        let now = Date().timeIntervalSince1970
        let diffTime = Int(now) - Int(feedItem.timestamp)
        var timeString = TimeFormatType.feed.timeString(diffTime)
        if let city = feedItem.city {
            timeString.append(" in \(city)")
        }
        timeLabel.text = timeString
        feedImageView.image = nil
        feedImageView.backgroundColor = UIColor.lightGray
        
        activityIndicator.startAnimating()
        let handleGifData: (FLAnimatedImage?)->Void = { [unowned self] animatedImage in
            self.feedImageView.animatedImage = animatedImage
        }
        if let animatedImage = gifDict[feedKey] {
            activityIndicator.stopAnimating()
            handleGifData(animatedImage)
        } else {
            if let firstImagePath = feedItem.imagePathArray.first {
                FirebaseService.sharedInstance.retrieveDataAtPath(path: firstImagePath, completion: { [unowned self] imageData in
                    if let image = UIImage(data: imageData) {
                        self.activityIndicator.stopAnimating()
                        self.feedImageView.image = image
                    }
                    self.gifCreation = {
                        self.playButton.isHidden = true
                        FeedViewController.createGifDataFrom(imagePathArray: feedItem.imagePathArray, completion: { data in
                            self.activityIndicator.stopAnimating()
                            let animatedImage = FLAnimatedImage(animatedGIFData: data)
                            handleGifData(animatedImage)
                            self.gifDict[feedKey] = animatedImage
                        })
                    }
                })
            }
        }
        
        if let comment = feedItem.comment, comment.characters.count > 0 {
            commentLabel.text = comment
            commentLabel.isHidden = false
            leftQuoteLabel.isHidden = false
            timeLabelTopConstraint.constant = 5
        } else {
            commentLabel.text = nil
            commentLabel.isHidden = true
            leftQuoteLabel.isHidden = true
            timeLabelTopConstraint.constant = -5
        }
        
        let nameText = "\(name) did \(feedItem.breathCount) breaths"
        let boldRange = rangeOfString(name, inString: nameText)
        let attrString = NSMutableAttributedString(string: nameText)
        let stringRange = NSRange(location: 0, length: nameText.characters.count)
        attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: ThemeManager.sharedInstance.focusForegroundColor(), range: stringRange)
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

    @IBAction func onPlayTap(_ sender: Any) {
        gifCreation?()
    }
    
    @IBAction func onRemoveTap(_ sender: Any) {
        optionsHandler?(feedKey)
    }
}
