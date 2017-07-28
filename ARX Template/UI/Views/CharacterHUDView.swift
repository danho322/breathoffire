//
//  CharacterHUDView.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/23/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

protocol CharacterHUDViewDelegate {
    func hudDidUpdateSlider(value: Float)
    func hudDidTapRewind()
    func hudDidTapPause()
    func hudDidTapPlay()
    func hudDidUpdateInstructorSwitch(isOn: Bool)
    func hudDidUpdateUkeSwitch(isOn: Bool)
    func hudDidTapShowToggle(shouldShow: Bool)
}

class CharacterHUDView: XibView {
    @IBOutlet weak var showBGView: UIView!
    @IBOutlet weak var showHudButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var backwardsButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var instructorSwitch: UISwitch!
    @IBOutlet weak var ukeSwitch: UISwitch!
    @IBOutlet weak var instructorSwitchLabel: UILabel!
    @IBOutlet weak var ukeSwitchLabel: UILabel!
    internal var sliderValue: Float = 0.5
    internal var isShowing = false
    internal var isPaused = true
    var delegate: CharacterHUDViewDelegate?

    override func setupUI() {
        guard let view = view as? CharacterHUDView else {
            fatalError("view is not of type CharacterHUDView")
        }
        
        let color = ThemeManager.sharedInstance.backgroundColor()
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = CGSize(width: Sizes.ScreenWidth, height: view.frame.size.height)
        gradient.colors = [color.withAlphaComponent(0).cgColor, color.cgColor] //Or any colors
        view.layer.insertSublayer(gradient, at: 0)
        
        updateShowHudButtonIcon(view: view)
        
        view.showBGView.backgroundColor = color
        
        let backwardIcon = FAKMaterialIcons.replayIcon(withSize: 25)
        backwardIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        view.backwardsButton.setAttributedTitle(backwardIcon?.attributedString(), for: .normal)
        
        let pauseIcon = FAKMaterialIcons.pauseIcon(withSize: 25)
        pauseIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        view.pauseButton.setAttributedTitle(pauseIcon?.attributedString(), for: .normal)
        
        view.instructorSwitchLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        view.instructorSwitchLabel.textColor = ThemeManager.sharedInstance.textColor()
        view.ukeSwitchLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        view.ukeSwitchLabel.textColor = ThemeManager.sharedInstance.textColor()
    }
    
    internal func updateShowHudButtonIcon(view: CharacterHUDView) {
        let buttonIcon = isShowing ? FAKIonIcons.iosArrowDownIcon(withSize: 25) : FAKIonIcons.iosArrowUpIcon(withSize: 25)
        buttonIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        view.showHudButton.setAttributedTitle(buttonIcon?.attributedString(), for: .normal)
    }
    
    @IBAction func onSliderTouchUpInside(_ sender: Any) {
        sliderValue = slider.value
        delegate?.hudDidUpdateSlider(value: sliderValue)
    }
    @IBAction func onSliderTouchUpOutside(_ sender: Any) {
        slider.value = sliderValue
    }
    
    @IBAction func onRewindTap(_ sender: Any) {
        delegate?.hudDidTapRewind()
    }
    
    @IBAction func onPauseTap(_ sender: Any) {
        if isPaused {
            delegate?.hudDidTapPause()
        } else {
            delegate?.hudDidTapPlay()
        }
        isPaused = !isPaused
        
        let icon = isPaused ? FAKMaterialIcons.pauseIcon(withSize: 25) : FAKMaterialIcons.playIcon(withSize: 25)
        icon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        pauseButton.setAttributedTitle(icon?.attributedString(), for: .normal)
    }
    
    @IBAction func onUkeSwitch(_ sender: Any) {
        delegate?.hudDidUpdateUkeSwitch(isOn: (sender as! UISwitch).isOn)
    }
    
    @IBAction func onInstructorSwitch(_ sender: Any) {
        delegate?.hudDidUpdateInstructorSwitch(isOn: (sender as! UISwitch).isOn)
    }
    
    @IBAction func onShowHudToggle(_ sender: Any) {
        isShowing = !isShowing
        updateShowHudButtonIcon(view: self)
        delegate?.hudDidTapShowToggle(shouldShow: isShowing)
    }
}
