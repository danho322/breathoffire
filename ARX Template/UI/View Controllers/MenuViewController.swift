//
//  MenuViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

class MenuViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var sportLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.alpha = 0
        FirebaseService.sharedInstance.retrieveBackgroundImage() { image in
            self.backgroundImageView.image = image
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn, animations: {
                self.backgroundImageView.alpha = 1
            })
            animator.startAnimation()
        }
        
        // Do any additional setup after loading the view.
        let gameIcon = FAKMaterialIcons.gamepadIcon(withSize: 25)
        gameIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        let infoIcon = FAKFoundationIcons.infoIcon(withSize: 25)
        infoIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        let settingIcon = FAKMaterialIcons.settingsIcon(withSize: 25)
        settingIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        enterButton.setAttributedTitle(gameIcon?.attributedString(), for: .normal)
        aboutButton.setAttributedTitle(infoIcon?.attributedString(), for: .normal)
        settingsButton.setAttributedTitle(settingIcon?.attributedString(), for: .normal)
        isHeroEnabled = true
        
        sportLabel.text = "Jiujitsu"
        sportLabel.alpha = 0
        sportLabel.alpha = 0
        
        sportLabelTopConstraint.constant = 100
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
            self.sportLabel.alpha = 1
            self.sportLabelTopConstraint.constant = 20
            self.view.layoutIfNeeded()
        })
        alphaAnimator.startAnimation()
    }
}
