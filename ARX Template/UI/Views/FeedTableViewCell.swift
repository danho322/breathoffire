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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func update(feedItem: BreathFeedItem) {
        var name = feedItem.userName
        if name.characters.count == 0 {
            name = "Anonymous"
        }
        nameLabel.text = name
        timeLabel.text = "Timestamp: \(feedItem.timestamp)"

        FirebaseService.sharedInstance.retrieveImageAtPath(path: feedItem.imagePath, completion: { image in
            self.feedImageView.image = image
        })
        
    }

}
