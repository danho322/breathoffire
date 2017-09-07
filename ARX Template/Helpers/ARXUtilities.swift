//
//  ARXUtilities.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/19/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import AVFoundation

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
    
    class func createThumbnailOfVideoFromFileURL(_ strVideoURL: URL) -> UIImage? {
        let asset = AVAsset(url: strVideoURL)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), 100)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            /* error handling here */
        }
        return nil
    }
}
