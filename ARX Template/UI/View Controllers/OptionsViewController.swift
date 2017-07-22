//
//  OptionsViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

struct OptionsConstants {
    static let MOTDIdentifier = "MOTDCellIdentifier"
}

class OptionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        let motdNib = UINib(nibName: "OptionsMOTDTableViewCell", bundle: nil)
        tableView.register(motdNib , forCellReuseIdentifier: OptionsConstants.MOTDIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.textColor()
        titleLabel.font = ThemeManager.sharedInstance.defaultFont(20)
        
        
        isHeroEnabled = true
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
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

extension OptionsViewController: UITableViewDelegate {

}

extension OptionsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: OptionsConstants.MOTDIdentifier, for: indexPath)
        if let cell = cell as? OptionsMOTDTableViewCell {
            cell.titleLabel.text = "\(indexPath.row)"
            cell.moveDescriptionLabel.text = "This is a realy long text that should span multiple lines so lets see if the cell with auto adjust"
        }
        return cell
    }
}
