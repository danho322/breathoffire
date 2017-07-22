//
//  OptionsMOTDTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/21/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class OptionsMOTDTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moveTitleLabel: UILabel!
    @IBOutlet weak var moveDescriptionLabel: UILabel!
    @IBOutlet weak var loadButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
