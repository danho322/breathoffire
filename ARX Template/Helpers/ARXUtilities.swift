//
//  ARXUtilities.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/19/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

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
    
    class func createGIF(with images: [UIImage], loopCount: Int = 0, frameDelay: Double, callback: (_ data: Data?, _ error: NSError?) -> ()) {
        let resizedImages = images.map({ image in
            return ARXUtilities.resizeImageWith(image: image, newSize: CGSize(width: 375, height: 375))
        })
        let fileProperties: [AnyHashable:Any] = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        
        let documentsDirectory = NSTemporaryDirectory()
        let url = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent("animated.gif")
        print(documentsDirectory)
        if let url = url,
            let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypeGIF, resizedImages.count, nil) {
            
            CGImageDestinationSetProperties(destination, fileProperties as CFDictionary)
            
            for i in 0..<resizedImages.count {
                CGImageDestinationAddImage(destination, resizedImages[i].cgImage!, frameProperties as CFDictionary)
            }
            
            if CGImageDestinationFinalize(destination) {
                let imageData = try? NSData(contentsOf: url) as Data
                callback(imageData, nil)
            } else {
                callback(nil, NSError())
            }
        } else  {
            callback(nil, NSError())
        }
    }
    
    class func resizeImageWith(image: UIImage, newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / image.size.width
        let verticalRatio = newSize.height / image.size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        var newImage: UIImage
        
        if #available(iOS 10.0, *) {
            let renderFormat = UIGraphicsImageRendererFormat.default()
            renderFormat.opaque = false
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: newSize.width, height: newSize.height), format: renderFormat)
            newImage = renderer.image {
                (context) in
                image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            }
        } else {
            UIGraphicsBeginImageContextWithOptions(CGSize(width: newSize.width, height: newSize.height), false, horizontalRatio)
            image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
            newImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
        }
        
        return newImage
    }
}
