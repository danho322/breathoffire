//
//  OptionsViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

class OptionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var workoutButton: UIButton!
    @IBOutlet weak var techniquesButton: UIButton!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        workoutButton.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        techniquesButton.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        exploreButton.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.textColor()
        titleLabel.font = ThemeManager.sharedInstance.defaultFont(20)
        
        
        isHeroEnabled = true
        
        let workoutIcon = FAKMaterialIcons.playCircleIcon(withSize: 25)
        workoutIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        let techniqueIcon = FAKFoundationIcons.listIcon(withSize: 25)
        techniqueIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        let exploreIcon = FAKMaterialIcons.searchIcon(withSize: 25)
        exploreIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        workoutButton.setAttributedTitle(workoutIcon?.attributedString(), for: .normal)
        techniquesButton.setAttributedTitle(techniqueIcon?.attributedString(), for: .normal)
        exploreButton.setAttributedTitle(exploreIcon?.attributedString(), for: .normal)
        backButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        hero_dismissViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let workoutVC = segue.destination as? TechniqueSceneKitViewController, let identifier = segue.identifier, identifier == "WorkoutIdentifier" {
            workoutVC.loadWorkout = true
            workoutVC.animationToLoad = DataLoader.sharedInstance.characterAnimation(name: "Salsa")
        }
    }
}
