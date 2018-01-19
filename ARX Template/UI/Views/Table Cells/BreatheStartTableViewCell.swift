//
//  BreatheStartTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 1/18/18.
//  Copyright © 2018 Daniel Ho. All rights reserved.
//

import UIKit
import SwiftySound

class BreatheStartTableViewCell: UITableViewCell {

    @IBOutlet weak var intentionTextField: HoshiTextField!
    @IBOutlet weak var liveSessionContainer: UIView!
    @IBOutlet weak var soloSessionContainer: UIView!
    @IBOutlet weak var selectedInfoLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var durationOutputLabel: UILabel!
    @IBOutlet weak var arModeLabel: UILabel!
    @IBOutlet weak var arModeSwitch: UISwitch!
    @IBOutlet weak var audioEnabledLabel: UILabel!
    @IBOutlet weak var audioEnabledSwitch: UISwitch!
    
    
    
    var startHandler: ((String?)->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        intentionTextField.textColor = ThemeManager.sharedInstance.textColor()
        intentionTextField.font = ThemeManager.sharedInstance.defaultFont(14)
        
        selectedInfoLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        selectedInfoLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        
        
        startButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        startButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        startButton.setTitle("Go", for: .normal)
        startButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(16)
        
        settingTitleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        settingTitleLabel.font = ThemeManager.sharedInstance.heavyFont(12)
        
        durationTitleLabel.textColor = ThemeManager.sharedInstance.textColor()
        durationTitleLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        durationSlider.tintColor = ThemeManager.sharedInstance.focusColor()
        
        durationOutputLabel.textColor = ThemeManager.sharedInstance.textColor()
        durationOutputLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        arModeLabel.textColor = ThemeManager.sharedInstance.textColor()
        arModeLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        audioEnabledLabel.textColor = ThemeManager.sharedInstance.textColor()
        audioEnabledLabel.font = ThemeManager.sharedInstance.defaultFont(14)

        liveSessionContainer.layer.borderWidth = 5
        soloSessionContainer.layer.borderWidth = 5
        
        let tap0 = UITapGestureRecognizer(target: self, action: #selector(self.onLiveTap))
        liveSessionContainer.addGestureRecognizer(tap0)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.onSoloTap))
        soloSessionContainer.addGestureRecognizer(tap1)
     
        onLiveTap(sender: self)
        audioEnabledSwitch.isOn = Sound.enabled
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - Tap Handlers
    
    @objc internal func onLiveTap(sender: AnyObject) {
        liveSessionContainer.layer.borderColor = ThemeManager.sharedInstance.focusColor().cgColor
        soloSessionContainer.layer.borderColor = ThemeManager.sharedInstance.foregroundColor().cgColor
//        selectedMode = .breathe
        selectedInfoLabel.text = "Create an open breathing session, where people around the world can join."
    }
    
    @objc internal func onSoloTap(sender: AnyObject) {
        liveSessionContainer.layer.borderColor = ThemeManager.sharedInstance.foregroundColor().cgColor
        soloSessionContainer.layer.borderColor = ThemeManager.sharedInstance.focusColor().cgColor
//        selectedMode = .jiujitsu
        selectedInfoLabel.text = "Start a focused breathing session on your own."
    }
    
    @IBAction func onStartTap(_ sender: Any) {
        // TODO: hook up duration and ar mode
        startHandler?(intentionTextField.text)
    }
    
    @IBAction func onDurationSliderChanged(_ sender: Any) {
        // TODO: hook up
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
