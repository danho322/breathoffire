//
//  FeedGifView.swift
//  ARX Template
//
//  Created by Daniel Ho on 10/30/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SDWebImage
import FontAwesomeKit

class FeedGifView: XibView {

    @IBOutlet weak var animatedImageView: FLAnimatedImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    internal var gifCreation: (()->Void)?
    internal var currentAnimatedKey: String?
    
    override func setupUI() {
        guard let view = view as? FeedGifView else {
            fatalError("view is not of type FeedGifView")
        }
        
        let playIcon = FAKMaterialIcons.playCircleIcon(withSize: 80)
        playIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        view.playButton.setAttributedTitle(playIcon?.attributedString(), for: .normal)
        
    }
    
    func onUpdate() {
        guard let view = view as? FeedGifView else {
            fatalError("view is not of type FeedGifView")
        }
        
//        view.playButton.isHidden = false
        view.gifCreation = nil
        view.animatedImageView.image = nil
        view.animatedImageView.backgroundColor = UIColor.lightGray
        view.activityIndicator.startAnimating()
    }
    
    
    func onImageDataLoad(imageData: Data, gifCreation: @escaping (()->Void)) {
        guard let view = view as? FeedGifView else {
            fatalError("view is not of type FeedGifView")
        }
        
        if let image = UIImage(data: imageData) {
            view.activityIndicator.stopAnimating()
            view.animatedImageView.image = image
        }
        
        view.gifCreation = gifCreation
    }
    
    func onAnimatedImageLoad(image: FLAnimatedImage?, key: String?) {
        guard let view = view as? FeedGifView else {
            fatalError("view is not of type FeedGifView")
        }
        
        if let key = key {
            if view.currentAnimatedKey == key {
                return
            }
        }
        view.currentAnimatedKey = key
        view.activityIndicator.stopAnimating()
        view.activityIndicator.isHidden = true
        view.animatedImageView.animatedImage = image
        view.playButton.isHidden = true
    }
    
    func startGifAnimation() {
        guard let view = view as? FeedGifView else {
            fatalError("view is not of type FeedGifView")
        }
        
        view.onPlayTap(self)
    }
    
    @IBAction func onPlayTap(_ sender: Any) {
        playButton.isHidden = true
        activityIndicator.startAnimating()
        gifCreation?()
    }
    
}
