//
//  ARXUtilities.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/19/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class ARXUtilities {
    class func heightFor(_ text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let cocoaString = NSString(string: text)
        let boundingBox = cocoaString.boundingRect(with: constraintRect,
                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                   attributes: [NSAttributedStringKey.font: font],
                                                   context: nil)
        return boundingBox.height + 5
    }
    
    class func widthFor(_ text: String, height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: height)
        let cocoaString = NSString(string: text)
        let boundingBox = cocoaString.boundingRect(with: constraintRect,
                                                   options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                   attributes: [NSAttributedStringKey.font: font],
                                                   context: nil)
        return boundingBox.width
    }
}
