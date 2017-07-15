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
    @IBOutlet weak var showHudButton: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var backwardsButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var instructorSwitch: UISwitch!
    @IBOutlet weak var ukeSwitch: UISwitch!
    internal var sliderValue: Float = 0.5
    internal var isShowing = false
    var delegate: CharacterHUDViewDelegate?

    override func setupUI() {
        guard let view = view as? CharacterHUDView else {
            fatalError("view is not of type CharacterHUDView")
        }
        
        updateShowHudButtonIcon(view: view)
        
        let backwardIcon = FAKMaterialIcons.replayIcon(withSize: 25)
        backwardIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        view.backwardsButton.setAttributedTitle(backwardIcon?.attributedString(), for: .normal)
        
        let pauseIcon = FAKMaterialIcons.pauseIcon(withSize: 25)
        pauseIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        view.pauseButton.setAttributedTitle(pauseIcon?.attributedString(), for: .normal)
        
        let forwardIcon = FAKMaterialIcons.playIcon(withSize: 25)
        forwardIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        view.forwardButton.setAttributedTitle(forwardIcon?.attributedString(), for: .normal)
    }
    
    internal func updateShowHudButtonIcon(view: CharacterHUDView) {
        let buttonIcon = isShowing ? FAKIonIcons.iosArrowDownIcon(withSize: 25) : FAKIonIcons.iosArrowUpIcon(withSize: 25)
        buttonIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
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
    
    @IBAction func onPlayTap(_ sender: Any) {
        delegate?.hudDidTapPlay()
    }
    
    @IBAction func onPauseTap(_ sender: Any) {
        delegate?.hudDidTapPause()
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
