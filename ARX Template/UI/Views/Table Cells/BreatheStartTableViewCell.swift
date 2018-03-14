//
//  BreatheStartTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 1/18/18.
//  Copyright © 2018 Daniel Ho. All rights reserved.
//

import UIKit
import SwiftySound
import iCarousel

class BreatheStartTableViewCell: UITableViewCell {

    @IBOutlet var ARModeSettingsTopConstraint: NSLayoutConstraint!
    @IBOutlet var ARModeDurationTopConstraint: NSLayoutConstraint!
    @IBOutlet var AudioSettingsTopConstraint: NSLayoutConstraint!
    @IBOutlet var AudioARTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var intentionTextField: HoshiTextField!
    @IBOutlet weak var selectedInfoLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var sessionTypeCarousel: iCarousel!
    
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationOutputLabel: UILabel!
    @IBOutlet weak var arModeLabel: UILabel!
    @IBOutlet weak var arModeSwitch: UISwitch!
    @IBOutlet weak var audioEnabledLabel: UILabel!
    @IBOutlet weak var audioEnabledSwitch: UISwitch!
    
    
    var startHandler: ((SessionType, String?, DurationSequenceType, Bool)->Void)?
    
    internal var selectedDurationSequenceType = DurationSequenceType.sequence6
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        intentionTextField.textColor = ThemeManager.sharedInstance.textColor()
        intentionTextField.placeholderColor = ThemeManager.sharedInstance.textColor()
        intentionTextField.borderInactiveColor = ThemeManager.sharedInstance.focusColor()
        intentionTextField.font = ThemeManager.sharedInstance.heavyFont(14)
        intentionTextField.text = StatManager.sharedIntance.lastIntention()
        intentionTextField.delegate = self
        
        selectedInfoLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        selectedInfoLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        
        startButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        startButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        startButton.setTitle("Start", for: .normal)
        startButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(16)
        
        settingTitleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        settingTitleLabel.font = ThemeManager.sharedInstance.heavyFont(12)
        
        durationTitleLabel.textColor = ThemeManager.sharedInstance.textColor()
        durationTitleLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        durationSlider.tintColor = ThemeManager.sharedInstance.iconColor()
        durationSlider.value = StatManager.sharedIntance.lastDurationSliderValue()
        onDurationSliderChanged(durationSlider)
        
        durationOutputLabel.textColor = ThemeManager.sharedInstance.textColor()
        durationOutputLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        arModeLabel.textColor = ThemeManager.sharedInstance.textColor()
        arModeLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        arModeSwitch.isOn = StatManager.sharedIntance.lastArMode()
        arModeSwitch.tintColor = ThemeManager.sharedInstance.iconColor()
        arModeSwitch.onTintColor = ThemeManager.sharedInstance.iconColor()
        
        audioEnabledLabel.textColor = ThemeManager.sharedInstance.textColor()
        audioEnabledLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        audioEnabledSwitch.tintColor = ThemeManager.sharedInstance.iconColor()
        audioEnabledSwitch.onTintColor = ThemeManager.sharedInstance.iconColor()

        sessionTypeCarousel.dataSource = self
        sessionTypeCarousel.delegate = self
        sessionTypeCarousel.type = .rotary
     
        updateUI(carouselIndex: 0)
        audioEnabledSwitch.isOn = Sound.enabled
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Tap Handlers
    
//    @objc internal func onLiveTap(sender: AnyObject) {
//        liveSessionContainer.layer.borderColor = ThemeManager.sharedInstance.focusColor().cgColor
////        liveSessionContainer.backgroundColor = ThemeManager.sharedInstance.focusColor()
//        soloSessionContainer.layer.borderColor = ThemeManager.sharedInstance.foregroundColor().cgColor
////        soloSessionContainer.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
//        selectedInfoLabel.text = "Create an open breathing session, where people around the world can join."
//
//        liveSessionImageView.tintColor = ThemeManager.sharedInstance.focusForegroundColor()
//        soloSessionImageView.tintColor = ThemeManager.sharedInstance.foregroundColor()
//    }
//
//    @objc internal func onSoloTap(sender: AnyObject) {
//        liveSessionContainer.layer.borderColor = ThemeManager.sharedInstance.foregroundColor().cgColor
////        liveSessionContainer.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
//        soloSessionContainer.layer.borderColor = ThemeManager.sharedInstance.focusColor().cgColor
////        soloSessionContainer.backgroundColor = ThemeManager.sharedInstance.focusColor()
//        selectedInfoLabel.text = "Start a focused breathing session on your own."
//
//        liveSessionImageView.tintColor = ThemeManager.sharedInstance.foregroundColor()
//        soloSessionImageView.tintColor = ThemeManager.sharedInstance.focusForegroundColor()
//    }
    
    @IBAction func onStartTap(_ sender: Any) {
        StatManager.sharedIntance.onIntentionPlay(intentionTextField.text ?? "",
                                                  durationSliderValue: durationSlider.value,
                                                  arMode: arModeSwitch.isOn)
        // TODO: hook up duration and ar mode
        let sessionType = SessionType(rawValue: sessionTypeCarousel.currentItemIndex) ?? SessionType.solo
        
        var isARMode = arModeSwitch.isOn
        if let sequenceName = sessionType.sequenceName() {
            isARMode = isARMode && DataLoader.sharedInstance.hasARAnimation(sequenceName: sequenceName)
        }
        
        startHandler?(sessionType, intentionTextField.text, selectedDurationSequenceType, isARMode)
    }
    
    @IBAction func onDurationSliderChanged(_ sender: Any) {
        // TODO: hook up
        if let slider = sender as? UISlider {
            var durationSequenceType: DurationSequenceType = .sequence6
            let total: Float = 7
            if slider.value < 1 / total {
                durationSequenceType = .sequence0
            } else if slider.value < 2 / total {
                durationSequenceType = .sequence1
            } else if slider.value < 3 / total {
                durationSequenceType = .sequence2
            } else if slider.value < 4 / total {
                durationSequenceType = .sequence3
            } else if slider.value < 5 / total {
                durationSequenceType = .sequence4
            } else if slider.value < 6 / total {
                durationSequenceType = .sequence5
            }
            selectedDurationSequenceType = durationSequenceType
            durationOutputLabel.text = durationSequenceType.labelText()
        }
    }
    
    @IBAction func onArModeSwitchChanged(_ sender: Any) {
        // TODO: hook up
    }
    
    @IBAction func onAudioEnabledSwitchChanged(_ sender: Any) {
        if let audioSwitch = sender as? UISwitch {
            Sound.enabled = audioSwitch.isOn
        }
    }
}

extension BreatheStartTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension BreatheStartTableViewCell: iCarouselDelegate {
    
    func updateUI(carouselIndex: Int) {
        if let type = SessionType(rawValue: carouselIndex) {
            selectedInfoLabel.text = type.infoString()
            let hasSequence: Bool = type.sequenceName() != nil
            durationSlider.isHidden = hasSequence
            durationOutputLabel.isHidden = hasSequence
            durationTitleLabel.isHidden = hasSequence
            ARModeDurationTopConstraint.isActive = !hasSequence
            ARModeSettingsTopConstraint.isActive = hasSequence
            var hasAnimation = true
            if let sequenceName = type.sequenceName() {
                hasAnimation = DataLoader.sharedInstance.hasARAnimation(sequenceName: sequenceName)
                arModeSwitch.isHidden = !hasAnimation
                arModeLabel.isHidden = !hasAnimation
            }
            AudioSettingsTopConstraint.isActive = !hasAnimation
            AudioARTopConstraints.isActive = hasAnimation
        }
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        updateUI(carouselIndex: carousel.currentItemIndex)
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
//        handlePackageTap(packageName: purchasedPackages[index].packageName)
    }
}

extension BreatheStartTableViewCell: iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return SessionType.count.rawValue
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var reusedView: UIView?
        
        //reuse view if available, otherwise create a new view
        if let view = view {
            reusedView = view
        } else {
            
            reusedView = UIView(frame: CGRect(x: 0, y: 0, width: carousel.frame.size.height, height: carousel.frame.size.height))
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: carousel.frame.size.height, height: carousel.frame.size.height))
            reusedView?.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
            reusedView?.layer.borderWidth = 5
            reusedView?.layer.borderColor = ThemeManager.sharedInstance.iconColor().cgColor

            if let type = SessionType(rawValue: index) {
                imageView.image = UIImage(named: type.imageName())
            }
            imageView.image = imageView.image!.withRenderingMode(.alwaysTemplate)
            imageView.tintColor = ThemeManager.sharedInstance.focusForegroundColor()
            
            
            reusedView?.contentMode = .scaleAspectFill
            reusedView?.layer.masksToBounds = true
            
            reusedView?.addSubview(imageView)
        }
        
        return reusedView!
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.9
        }
        return value
    }
}
