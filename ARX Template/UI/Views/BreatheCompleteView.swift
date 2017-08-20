//
//  BreatheCompleteView.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/12/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit
import HCSStarRatingView

class BreatheCompleteView: XibView {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailsLabel: UILabel!
    @IBOutlet weak var screenshotImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var communityButton: UIButton!
    @IBOutlet weak var communityCheckmarkImageView: UIImageView!
    @IBOutlet weak var ratingTitleLabel: UILabel!
    @IBOutlet weak var ratingView: HCSStarRatingView!
    @IBOutlet weak var ratingHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spacerHeightConstraint: NSLayoutConstraint!
    
    
    weak var parentVC: UIViewController?
    var shareCommunityHandler: ((Int?, String?)->Void)?
    var dismissHandler: (()->Void)?
    
    internal var ratingValue: Int?
    internal var didShareFeed = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    convenience init(frame: CGRect, parentVC: UIViewController, shareCommunityHandler: ((Int?, String?)->Void)?, dismissHandler: (()->Void)?) {
        self.init(frame: frame)
        self.parentVC = parentVC
        self.shareCommunityHandler = shareCommunityHandler
        self.dismissHandler = dismissHandler
    }
    
    override func setupUI() {
        guard let view = view as? BreatheCompleteView else {
            fatalError("view is not of type BreatheCompleteView")
        }
        
        view.containerView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        view.titleLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        view.detailsLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        view.ratingTitleLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        
        view.titleLabel.font = ThemeManager.sharedInstance.defaultFont(40)
        view.detailsLabel.font = ThemeManager.sharedInstance.defaultFont(20)
        view.ratingTitleLabel.font = ThemeManager.sharedInstance.defaultFont(20)
        
        let shareIcon = FAKMaterialIcons.shareIcon(withSize: 25)
        shareIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusColor())
        view.shareButton.setAttributedTitle(shareIcon?.attributedString(), for: .normal)
        
        view.communityButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        view.communityButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(16)
        view.communityButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        view.dismissButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        let circleIcon = FAKIonIcons.iosCircleOutlineIcon(withSize: 25)
        circleIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
        
        view.communityCheckmarkImageView.image = circleIcon?.image(with: CGSize(width: 25, height: 25))
        
        view.ratingView.minimumValue = 0
        view.ratingView.maximumValue = 5
        view.ratingView.value = 0
        view.ratingView.addTarget(self, action: #selector(onRatingValueChanged(ratingView:)), for: .valueChanged)
    
        view.commentTextView.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        view.commentTextView.textColor = ThemeManager.sharedInstance.textColor()
        view.commentTextView.font = ThemeManager.sharedInstance.defaultFont(16)
        
        NotificationCenter.default.addObserver(self, selector: #selector(BreatheCompleteView.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BreatheCompleteView.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let view = view as? BreatheCompleteView else {
            fatalError("view is not of type LoginView")
        }
        
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey]
        
        if let keyboardFrame = keyboardFrame {
            if let frame = (keyboardFrame as AnyObject).cgRectValue {
                
                view.spacerHeightConstraint.constant = frame.size.height
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        guard let view = view as? BreatheCompleteView else {
            fatalError("view is not of type LoginView")
        }
        
        view.spacerHeightConstraint.constant = 0
    }
    
    // artechniqueviewcontroller needs to be refactored to hold the container
    func update(breathCount: Int, screenshot: UIImage?, sequenceContainer: AnimationSequenceDataContainer?) {
        guard let view = view as? BreatheCompleteView else {
            fatalError("view is not of type BreatheCompleteView")
        }
        view.detailsLabel.text = "You did \(breathCount) Breaths of Fire!"
        view.screenshotImageView.image = screenshot
        view.screenshotImageView.layer.masksToBounds = true
        view.screenshotImageView.layer.cornerRadius = view.screenshotImageView.frame.size.width / 2
    }
    
    // MARK: - Button Handlers
    
    @objc func onRatingValueChanged(ratingView: HCSStarRatingView) {
        ratingValue = Int(ratingView.value)
    }
    
    @IBAction func onShareTap(_ sender: Any) {
        var viewToUse = self
        if let superview = self.superview as? BreatheCompleteView {
            viewToUse = superview
        }
        
//        let pasteBoard = UIPasteboard.general
//        pasteBoard.string = link
        
        if let imageToShare = screenshotImageView.image {
            let objectsToShare = [imageToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = view
            viewToUse.parentVC?.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func onCommunityTap(_ sender: Any) {
        if didShareFeed {
            return
        }
        
        didShareFeed = true
        
        var viewToUse = self
        if let superview = self.superview as? BreatheCompleteView {
            viewToUse = superview
        }
        
        let circleIcon = FAKIonIcons.iosCheckmarkOutlineIcon(withSize: 25)
        circleIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
        communityCheckmarkImageView.image = circleIcon?.image(with: CGSize(width: 25, height: 25))
        
        viewToUse.shareCommunityHandler?(viewToUse.ratingValue, commentTextView.text)
 
        ratingTitleLabel.isHidden = true
        ratingHeightConstraint.constant = 0
        commentHeightConstraint.constant = 0
    }
    
    @IBAction func onDismissTap(_ sender: Any) {
        var viewToDismiss = self
        if let superview = self.superview as? BreatheCompleteView {
            viewToDismiss = superview
        }
        
        viewToDismiss.animateOut() { [unowned self] in
            viewToDismiss.dismissHandler?()
        }
    }
    
    // MARK: - Aniamtions
    
    func animateIn() {
        guard let view = view as? BreatheCompleteView else {
            fatalError("view is not of type BreatheCompleteView")
        }
        
        let offset: CGFloat = 50
        view.alpha = 0
        view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + offset, width: view.frame.size.width, height: view.frame.size.height)
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            view.alpha = 1
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - offset, width: view.frame.size.width, height: view.frame.size.height)
        })
        alphaAnimator.startAnimation()
    }
    
    func animateOut(completion: @escaping (()->Void)) {
        guard let view = view as? BreatheCompleteView else {
            fatalError("view is not of type BreatheCompleteView")
        }
        
        let offset: CGFloat = -50
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            view.alpha = 0
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - offset, width: view.frame.size.width, height: view.frame.size.height)
        })
        alphaAnimator.addCompletion({ position in
            self.removeFromSuperview()
            completion()
        })
        alphaAnimator.startAnimation()
    }
}
