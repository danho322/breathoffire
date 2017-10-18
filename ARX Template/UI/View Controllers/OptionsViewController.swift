//
//  OptionsViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit
import Instructions
import SwiftyStoreKit

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
                let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width - 5, height: 50))
                label.backgroundColor = UIColor.clear
                label.textColor = ThemeManager.sharedInstance.labelTitleColor()
                label.font = ThemeManager.sharedInstance.heavyFont(16)
                label.text = "Lessons"
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
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressVisualEffectView: UIVisualEffectView!
    
    internal var sectionArray: [OptionCellSectionType] = []
    let coachMarksController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Breathe"
        
        StoreKitService().retrieveProductData()
        
        progressLabel.font = ThemeManager.sharedInstance.defaultFont(20)
        progressLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        FirebaseService.sharedInstance.downloadDelegate = self
        progressVisualEffectView.isHidden = !FirebaseService.sharedInstance.isDownloadingDB
        
        coachMarksController.dataSource = self
        coachMarksController.overlay.color = ThemeManager.sharedInstance.backgroundColor(alpha: 0.8)
        
        var sections: [OptionCellSectionType] = []
        sections.append(.moveOfDay)
//        let packages = DataLoader.sharedInstance.packages()
//        for package in packages {
//            let hasPackage = SessionManager.sharedInstance.hasPackage(packageName: package.packageName)
//            if hasPackage {
//                sections.append(.myPackages)
//                break
//            }
//        }
        sections.append(.packages)
//        sections.append(.techniqueList)
        sectionArray = sections
        
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()

        let motdNib = UINib(nibName: String(describing: OptionsMOTDTableViewCell.self), bundle: nil)
        tableView.register(motdNib , forCellReuseIdentifier: CellIdentifiers.MOTD)
//        let packagesNib = UINib(nibName: String(describing: OptionsMyPackagesTableViewCell.self), bundle: nil)
//        tableView.register(packagesNib , forCellReuseIdentifier: CellIdentifiers.MyPackages)
        let packageNib = UINib(nibName: String(describing: OptionsPackageTableViewCell.self), bundle: nil)
        tableView.register(packageNib , forCellReuseIdentifier: CellIdentifiers.Package)
        let techniquesNib = UINib(nibName: String(describing: OptionsTechniquesTableViewCell.self), bundle: nil)
        tableView.register(techniquesNib , forCellReuseIdentifier: CellIdentifiers.ViewAllTechniques)
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        
        ThemeManager.sharedInstance.formatSearchBar(searchBar)
        
        isHeroEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkShouldStartTutorial()
    }
    
    func checkShouldStartTutorial() {
        if !FirebaseService.sharedInstance.isDownloadingDB && SessionManager.sharedInstance.shouldShowTutorial(type: .Options) {
            coachMarksController.start(on: self)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
        SessionManager.sharedInstance.onTutorialShow(type: .Options)
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
            let packageName = DataLoader.sharedInstance.packages()[indexPath.row].packageName
            let hasPackage = SessionManager.sharedInstance.hasPackage(packageName: packageName)
            if hasPackage {
                handlePackageTap(packageName: packageName)
            } else {
                if let packageDetailsVC = storyboard?.instantiateViewController(withIdentifier: "PackageDetailsIdentifier") as? PackageDetailsViewController {
                    packageDetailsVC.packageName = packageName
                    navigationController?.pushViewController(packageDetailsVC, animated: true)
                }
            }
        } else if section == .moveOfDay {
//            if let sceneVC = segue.destination as? ARTechniqueViewController, let identifier = segue.identifier, identifier == "ARSegue" {
//                sceneVC.sequenceToLoad = sequenceToLoad
//            }
            if let arVC = storyboard?.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController,
                let motdSequenceContainer = DataLoader.sharedInstance.moveOfTheDay() {
                arVC.sequenceToLoad = motdSequenceContainer
//                arVC.isARModeEnabled = false
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
                        cell.titleLabel.text = "Daily Exercise"
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
            cell.update(package: package)

        }
        return cell
    }
}

extension OptionsViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 2
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        return coachMarksController.helper.makeCoachMark(for: tableView.cellForRow(at: IndexPath(row: 0, section: index)))
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        let hintText = index == 0 ? "Here is the daily exercise" : "Here are the pacakges"
        coachViews.bodyView.hintLabel.text = hintText
        coachViews.bodyView.nextLabel.text = "Ok"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

extension OptionsViewController: FirebaseServiceDelegate {
    func firebaseServiceSectionDownloaded(count: Int, total: Int) {
        progressLabel.text = "Updated \(count) of \(total)..."
    }
    
    func firebaseServiceSectionDownloadFinish() {
        progressVisualEffectView.isHidden = true
        checkShouldStartTutorial()
    }
}
