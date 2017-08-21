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
}

enum OptionCellSectionType {
    case moveOfDay, myPackages, packages, techniqueList
    
    func rowCount() -> Int {
        switch self {
        case .moveOfDay, .myPackages, .techniqueList:
            return 1
        case .packages:
            return DataLoader.sharedInstance.packages().count
        }
    }
    
    func sectionHeaderHeight(section: Int) -> CGFloat {
        switch self {
        case .packages:
            return 50
        default:
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func sectionHeaderView(tableView: UITableView? = nil) -> UIView {
        switch self {
        case .packages:
            if let tableView = tableView {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
                headerView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
                let label = UILabel(frame: CGRect(x: 5, y: 0, width: tableView.frame.size.width - 5, height: 50))
                label.backgroundColor = UIColor.clear
                label.textColor = ThemeManager.sharedInstance.labelTitleColor()
                label.font = ThemeManager.sharedInstance.heavyFont(16)
                label.text = "Available Packages"
                headerView.addSubview(label)
                return headerView
            }
        default:
            break
        }
        return UIView()
    }
}

class OptionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    internal var sectionArray: [OptionCellSectionType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Breathe"
        
        sectionArray = [.moveOfDay, .myPackages, .packages, .techniqueList]

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()

        let motdNib = UINib(nibName: String(describing: OptionsMOTDTableViewCell.self), bundle: nil)
        tableView.register(motdNib , forCellReuseIdentifier: CellIdentifiers.MOTD)
        let packagesNib = UINib(nibName: String(describing: OptionsMyPackagesTableViewCell.self), bundle: nil)
        tableView.register(packagesNib , forCellReuseIdentifier: CellIdentifiers.MyPackages)
        let packageNib = UINib(nibName: String(describing: OptionsPackageTableViewCell.self), bundle: nil)
        tableView.register(packageNib , forCellReuseIdentifier: CellIdentifiers.Package)
        let techniquesNib = UINib(nibName: String(describing: OptionsTechniquesTableViewCell.self), bundle: nil)
        tableView.register(techniquesNib , forCellReuseIdentifier: CellIdentifiers.ViewAllTechniques)
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        
        ThemeManager.sharedInstance.formatSearchBar(searchBar)
        
        isHeroEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        hero_dismissViewController()
    }
    
    func handlePackageTap(packageName: String?) {
        if let techniqueVC = storyboard?.instantiateViewController(withIdentifier: "CharacterAnimationPickerIdentifier") as? CharacterAnimationPickerViewController {
            techniqueVC.packageName = packageName
            navigationController?.pushViewController(techniqueVC, animated: true)
        }
    }
}

extension OptionsViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let searchVC = storyboard?.instantiateViewController(withIdentifier: "TechniqueSearchIdentifier") {
            navigationController?.pushViewController(searchVC, animated: true)
        }
    }
}


extension OptionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sectionArray[indexPath.section]
        if section == .packages {
            if let packageDetailsVC = storyboard?.instantiateViewController(withIdentifier: "PackageDetailsIdentifier") as? PackageDetailsViewController {
                packageDetailsVC.packageName = DataLoader.sharedInstance.packages()[indexPath.row].packageName
                navigationController?.pushViewController(packageDetailsVC, animated: true)
            }
        } else if section == .moveOfDay {
//            if let sceneVC = segue.destination as? ARTechniqueViewController, let identifier = segue.identifier, identifier == "ARSegue" {
//                sceneVC.sequenceToLoad = sequenceToLoad
//            }
            if let arVC = storyboard?.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController,
                let motdSequenceContainer = DataLoader.sharedInstance.moveOfTheDay() {
                arVC.sequenceToLoad = motdSequenceContainer
                arVC.dismissCompletionHandler = { [unowned self] in
                    self.navigationController?.popToRootViewController(animated: true)
                    self.tabBarController?.selectedIndex = 0
                }
                present(arVC, animated: true, completion: nil)
            }
        } else {
            handlePackageTap(packageName: "Jiujitsu Basics")
//            if let breatheVC = storyboard?.instantiateViewController(withIdentifier: "BreatheViewControllerIdentifier") as? BreatheViewController {
//                present(breatheVC, animated: true, completion: nil)
//            }
        }
    }
}

extension OptionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionArray[section].rowCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if let sectionType = sectionArray[safe: indexPath.section] {
            if sectionType == .moveOfDay {
                cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.MOTD, for: indexPath)
                if let cell = cell as? OptionsMOTDTableViewCell {
                    if let motd = DataLoader.sharedInstance.moveOfTheDay() {
                        cell.titleLabel.text = "Move of the day"
                        cell.moveTitleLabel.text = motd.sequenceName
                        cell.moveDescriptionLabel.text = motd.sequenceDescription
                    }
                }
            } else if sectionType == .myPackages {
                cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.MyPackages, for: indexPath)
                if let cell = cell as? OptionsMyPackagesTableViewCell {
                    cell.update() { [unowned self] packageName in
                        self.handlePackageTap(packageName: packageName)
                    }
                }
            } else if sectionType == .packages {
                cell = packageCell(tableView, indexPath: indexPath)
            } else if sectionType == .techniqueList {
                cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.ViewAllTechniques, for: indexPath)
                if let cell = cell as? OptionsTechniquesTableViewCell {
                }
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionArray[section].sectionHeaderView(tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionArray[section].sectionHeaderHeight(section: section)
    }
    
    func packageCell(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.Package, for: indexPath)
        if let cell = cell as? OptionsPackageTableViewCell {
            let package = DataLoader.sharedInstance.packages()[indexPath.row]
            cell.packageNameLabel.text = package.packageName
            cell.packageDescriptionLabel.text = package.packageDescription
            FirebaseService.sharedInstance.retrieveImageAtPath(path: package.imageBGPath) { image in
                cell.bgImageView.image = image
            }
            
            let techniques = DataLoader.sharedInstance.sequencesInPackage(packageName: package.packageName)
            cell.techniqueCountTagLabel.text = "\(techniques.count) TECHNIQUES"

        }
        return cell
    }
}
