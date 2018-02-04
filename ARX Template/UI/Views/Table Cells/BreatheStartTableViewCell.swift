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
    @IBOutlet weak var liveSessionImageView: UIImageView!
    @IBOutlet weak var soloSessionContainer: UIView!
    @IBOutlet weak var soloSessionImageView: UIImageView!
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
    
    
    var startHandler: ((String?, DurationSequenceType, Bool)->Void)?
    
    internal var selectedDurationSequenceType = DurationSequenceType.sequence6
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        intentionTextField.textColor = ThemeManager.sharedInstance.textColor()
        intentionTextField.font = ThemeManager.sharedInstance.defaultFont(14)
        intentionTextField.text = StatManager.sharedIntance.lastIntention()
        intentionTextField.delegate = self
        
        selectedInfoLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        selectedInfoLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        
        liveSessionContainer.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        soloSessionContainer.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        
        liveSessionImageView.image = liveSessionImageView.image!.withRenderingMode(.alwaysTemplate)
        soloSessionImageView.image = soloSessionImageView.image!.withRenderingMode(.alwaysTemplate)
        
        startButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        startButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        startButton.setTitle("Go", for: .normal)
        startButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(16)
        
        settingTitleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        settingTitleLabel.font = ThemeManager.sharedInstance.heavyFont(12)
        
        durationTitleLabel.textColor = ThemeManager.sharedInstance.textColor()
        durationTitleLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        durationSlider.tintColor = ThemeManager.sharedInstance.focusColor()
        durationSlider.value = StatManager.sharedIntance.lastDurationSliderValue()
        onDurationSliderChanged(durationSlider)
        
        durationOutputLabel.textColor = ThemeManager.sharedInstance.textColor()
        durationOutputLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        arModeLabel.textColor = ThemeManager.sharedInstance.textColor()
        arModeLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        arModeSwitch.isOn = StatManager.sharedIntance.lastArMode()
        
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
//        liveSessionContainer.backgroundColor = ThemeManager.sharedInstance.focusColor()
        soloSessionContainer.layer.borderColor = ThemeManager.sharedInstance.foregroundColor().cgColor
//        soloSessionContainer.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        selectedInfoLabel.text = "Create an open breathing session, where people around the world can join."
        
        liveSessionImageView.tintColor = ThemeManager.sharedInstance.focusForegroundColor()
        soloSessionImageView.tintColor = ThemeManager.sharedInstance.foregroundColor()
    }
    
    @objc internal func onSoloTap(sender: AnyObject) {
        liveSessionContainer.layer.borderColor = ThemeManager.sharedInstance.foregroundColor().cgColor
//        liveSessionContainer.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        soloSessionContainer.layer.borderColor = ThemeManager.sharedInstance.focusColor().cgColor
//        soloSessionContainer.backgroundColor = ThemeManager.sharedInstance.focusColor()
        selectedInfoLabel.text = "Start a focused breathing session on your own."
        
        liveSessionImageView.tintColor = ThemeManager.sharedInstance.foregroundColor()
        soloSessionImageView.tintColor = ThemeManager.sharedInstance.focusForegroundColor()
    }
    
    @IBAction func onStartTap(_ sender: Any) {
        StatManager.sharedIntance.onIntentionPlay(intentionTextField.text ?? "",
                                                  durationSliderValue: durationSlider.value,
                                                  arMode: arModeSwitch.isOn)
        // TODO: hook up duration and ar mode
        startHandler?(intentionTextField.text, selectedDurationSequenceType, arModeSwitch.isOn)
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
