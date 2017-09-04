//
//  MenuViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit
import SceneKit
import MapKit

enum ModeType {
    case none, breathe, jiujitsu
}

class MenuViewController: UIViewController {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var sportLabel: UILabel!
    @IBOutlet weak var sportLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var aboutButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var sceneContainer0: UIView!
    @IBOutlet weak var sceneContainer1: UIView!
    
    internal var selectedMode = ModeType.none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        backgroundImageView.alpha = 0
        FirebaseService.sharedInstance.retrieveBackgroundImage() { image in
            self.backgroundImageView.image = image
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeIn, animations: {
                self.backgroundImageView.alpha = 1
                self.appLabel.alpha = 0
                self.sportLabel.alpha = 0
            })
            animator.startAnimation()
        }
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        enterButton.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        aboutButton.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        settingsButton.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        sportLabel.textColor = ThemeManager.sharedInstance.textColor()
        sportLabel.font = ThemeManager.sharedInstance.defaultFont(20)
        appLabel.textColor = ThemeManager.sharedInstance.textColor()
        appLabel.font = ThemeManager.sharedInstance.heavyFont(24)
        selectLabel.textColor = ThemeManager.sharedInstance.textColor()
        selectLabel.font = ThemeManager.sharedInstance.heavyFont(20)

        let gameIcon = FAKMaterialIcons.gamepadIcon(withSize: 25)
        gameIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        let infoIcon = FAKFoundationIcons.infoIcon(withSize: 25)
        infoIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        let settingIcon = FAKMaterialIcons.settingsIcon(withSize: 25)
        settingIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        enterButton.setAttributedTitle(gameIcon?.attributedString(), for: .normal)
        aboutButton.setAttributedTitle(infoIcon?.attributedString(), for: .normal)
        settingsButton.setAttributedTitle(settingIcon?.attributedString(), for: .normal)
        isHeroEnabled = true

        sportLabel.text = "Jiujitsu"
        sportLabel.alpha = 0
        sportLabel.alpha = 0
        
        selectLabel.text = "SELECT MODE"
        selectLabel.alpha = 0
        sceneContainer0.alpha = 0
        sceneContainer1.alpha = 0
        
        sceneContainer0.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        sceneContainer1.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let borderWidth: CGFloat = 4
            let sceneFrame0 = CGRect(x: borderWidth, y: borderWidth, width: self.sceneContainer0.frame.size.width - 2 * borderWidth, height: self.sceneContainer0.frame.size.height - 2 * borderWidth)
            let sceneFrame1 = CGRect(x: borderWidth, y: borderWidth, width: self.sceneContainer1.frame.size.width - 2 * borderWidth, height: self.sceneContainer1.frame.size.height - 2 * borderWidth)
            
            let characterScene0 = ARXCharacterSceneView(frame: sceneFrame0, cameraPosition: SCNVector3(x: 0, y: 0.3, z: 2))
            characterScene0.isUserInteractionEnabled = false
            let characterScene1 = ARXCharacterSceneView(frame: sceneFrame1, characterRotation: SCNVector4Make(0, 1, 0, -Float(Double.pi)))
            characterScene1.isUserInteractionEnabled = false
            
            if let fire = SCNParticleSystem(named: "Fire.scnp", inDirectory: nil) {
                characterScene0.model?.childNode(withName: "spine_03", recursively: true)?.addParticleSystem(fire)
            }

            let data0 = DataLoader.sharedInstance.characterAnimation(name: "Menu Meditation")
            characterScene0.repeatAnimationData(data: data0)
            characterScene1.repeatAnimationData(data: DataLoader.sharedInstance.characterAnimation(name: "Movement Test 1"))
            
            self.sceneContainer0.addSubview(characterScene0)
            self.sceneContainer1.addSubview(characterScene1)
            
            let tap0 = UITapGestureRecognizer(target: self, action: #selector(self.onScene0Tap))
            self.sceneContainer0.addGestureRecognizer(tap0)
            
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(self.onScene1Tap))
            self.sceneContainer1.addGestureRecognizer(tap1)
            
            self.sportLabelTopConstraint.constant = 100
            let alphaAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
                self.sportLabel.alpha = 1
                self.selectLabel.alpha = 1
                self.sceneContainer0.alpha = 1
                self.sceneContainer1.alpha = 1
                self.sportLabelTopConstraint.constant = 20
            })
            alphaAnimator.startAnimation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func onLoginTap(_ sender: Any) {
        
    }
    
    @IBAction func onSettingsTap(_ sender: Any) {
        
    }
    
    @IBAction func onEnterTap(_ sender: Any) {
        if selectedMode == .none {
            let alert = UIAlertController(title: "Template Alert", message: "Please select mode", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            if let optionsVC = self.storyboard?.instantiateViewController(withIdentifier: "OptionsIdentifier") as? OptionsViewController {
                navigationController?.pushViewController(optionsVC, animated: true)
//                optionsVC.titleLabel.text = selectLabel.text
            }
        }
    }
    
    @objc internal func onScene0Tap(sender: AnyObject) {
        sceneContainer0.backgroundColor = ThemeManager.sharedInstance.focusColor()
        sceneContainer1.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        selectedMode = .breathe
        selectLabel.text = "BREATHE"
    }
    
    @objc internal func onScene1Tap(sender: AnyObject) {
        sceneContainer0.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        sceneContainer1.backgroundColor = ThemeManager.sharedInstance.focusColor()
        selectedMode = .jiujitsu
        selectLabel.text = "JIUJITSU"
    }
}
