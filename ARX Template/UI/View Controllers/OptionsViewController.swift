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

    @IBOutlet weak var workoutButton: UIButton!
    @IBOutlet weak var techniquesButton: UIButton!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        isHeroEnabled = true
        
        let workoutIcon = FAKMaterialIcons.playCircleIcon(withSize: 25)
        workoutIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        let techniqueIcon = FAKFoundationIcons.listIcon(withSize: 25)
        techniqueIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        let exploreIcon = FAKMaterialIcons.searchIcon(withSize: 25)
        exploreIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.black)
        
        workoutButton.setAttributedTitle(workoutIcon?.attributedString(), for: .normal)
        techniquesButton.setAttributedTitle(techniqueIcon?.attributedString(), for: .normal)
        exploreButton.setAttributedTitle(exploreIcon?.attributedString(), for: .normal)
        backButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        
        
        FirebaseService.sharedInstance.retrieveDB()
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
