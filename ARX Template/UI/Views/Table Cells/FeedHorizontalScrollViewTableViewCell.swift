//
//  FeedHorizontalScrollViewTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 10/29/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit
import SDWebImage

class FeedHorizontalScrollViewTableViewCell: UITableViewCell {

    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var paginatedScrollView: PaginatedScrollView!
    
    internal var concatenatedKey = ""
    internal var optionsHandler: ((String?)->Void)?
    internal var gifDict: [String: FLAnimatedImage] = Dictionary<String, FLAnimatedImage>()
    internal var gifCreationDict: [String: (()->Void)] = Dictionary<String, (()->Void)>()
    internal var keyArray: [String?] = []
    internal var currentKey: String?
    internal var gifViews: [FeedGifView] = []
    internal var isFirstGifLoad = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        optionsButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        optionsButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(16)
    }
    
    func update(feedItems: [BreathFeedItem], optionsHandler: @escaping ((String?)->Void), outerScrollView: UIScrollView?) {
        let thisKey = feedItems.map({ $0.key ?? "" }).joined()
        if thisKey == concatenatedKey {
            return
        }
        concatenatedKey = thisKey
        
        self.optionsHandler = optionsHandler
        
        keyArray = []
        gifViews = []
        
        for feedItem in feedItems {
            if let gifView = createFeedGifView(for: feedItem) {
                gifViews.append(gifView)
                keyArray.append(feedItem.key)
            }
        }
        
        paginatedScrollView.setPageViews(pageViewArray: gifViews, delegate: self, outerScrollView: outerScrollView)
    }
    
    internal func createFeedGifView(for feedItem: BreathFeedItem) -> FeedGifView? {
        guard let feedKey = feedItem.key else {
            return nil
        }
        
        let feedGifView = FeedGifView()
        feedGifView.onUpdate()

        if let animatedImage = gifDict[feedKey] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                feedGifView.onAnimatedImageLoad(image: animatedImage, key: feedKey)
            })
        } else {
            if let firstImagePath = feedItem.imagePathArray.first {
                FirebaseService.sharedInstance.retrieveDataAtPath(path: firstImagePath, completion: { [unowned self] imageData in
                    feedGifView.onImageDataLoad(imageData: imageData,
                                                gifCreation: {
                                                    FeedViewController.createGifDataFrom(imagePathArray: feedItem.imagePathArray, completion: { data in
                                                        let animatedImage = FLAnimatedImage(animatedGIFData: data)
                                                        feedGifView.onAnimatedImageLoad(image: animatedImage, key: feedItem.key)
                                                        self.gifDict[feedKey] = animatedImage
                                                    })
                    })
                    if self.isFirstGifLoad {
                        self.isFirstGifLoad = false
                        feedGifView.startGifAnimation()
                    }
                })
            }
        }
        
        return feedGifView
    }

    @IBAction func onOptionsTap(_ sender: Any) {
        optionsHandler?(currentKey)
    }
}

extension FeedHorizontalScrollViewTableViewCell: PaginatedScrollViewDelegate {
    func scrollViewDidUpdateToIndex(scrollView: PaginatedScrollView, index: Int) {
        currentKey = keyArray[index]
        gifViews[index].startGifAnimation()
    }
    
    func scrollViewDidTapView(scrollView: PaginatedScrollView, view: UIView?, index: Int) {
        
    }
}
