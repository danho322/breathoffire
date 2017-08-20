//
//  PackageDetailsViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/23/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

struct PackageDetailsConstants {
}

enum PackageDetailsSection {
    case description, techniqueSequences
    
    func rowCount(packageName: String) -> Int {
        switch self {
        case .description:
            return 1
        case .techniqueSequences:
            return DataLoader.sharedInstance.sequencesInPackage(packageName: packageName).count
        }
    }
    
    func sectionHeaderHeight(section: Int) -> CGFloat {
        switch self {
        case .techniqueSequences, .description:
            return 50
        default:
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func sectionHeaderView(tableView: UITableView? = nil) -> UIView {
        switch self {
        case .description:
            if let tableView = tableView {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
                headerView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
                let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width - 15, height: 50))
                label.backgroundColor = UIColor.clear
                label.textColor = ThemeManager.sharedInstance.labelTitleColor()
                label.font = ThemeManager.sharedInstance.heavyFont(16)
                label.text = "Package Description"
                headerView.addSubview(label)
                return headerView
            }
        case .techniqueSequences:
            if let tableView = tableView {
                let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
                headerView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
                let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width - 15, height: 50))
                label.backgroundColor = UIColor.clear
                label.textColor = ThemeManager.sharedInstance.labelTitleColor()
                label.font = ThemeManager.sharedInstance.heavyFont(16)
                label.text = "Techniques included"
                headerView.addSubview(label)
                return headerView
            }
        default:
            break
        }
        return UIView()
    }
}

class PackageDetailsViewController: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var packageNameLabel: UILabel!
    @IBOutlet weak var instructorScrollView: UIScrollView!
    @IBOutlet weak var instructorProfileImageView: UIImageView!
    @IBOutlet weak var instructorNameLabel: UILabel!
    @IBOutlet weak var instructorDetailLabel: UILabel!
    @IBOutlet weak var instructorDescriptionLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var packageName: String?
    internal var sectionArray: [PackageDetailsSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isHeroEnabled = true

        // Do any additional setup after loading the view.

        let descriptionNib = UINib(nibName: String(describing: PackageDetailsDescriptionTableViewCell.self), bundle: nil)
        tableView.register(descriptionNib , forCellReuseIdentifier: CellIdentifiers.PackageDescription)
        let techniqueNib = UINib(nibName: String(describing: TechniqueTableCell.self), bundle: nil)
        tableView.register(techniqueNib , forCellReuseIdentifier: CellIdentifiers.Technique)
        
        sectionArray = [.description, .techniqueSequences]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        
//        backgroundImageView.sd_setImage(with: URL(string: "http://graciescottsdale.com/wp-scottsdale/uploads/2014/01/Helio-Flying-680x307.jpg"))
        
        packageNameLabel.textColor = ThemeManager.sharedInstance.textColor()
        packageNameLabel.font = ThemeManager.sharedInstance.heavyFont(20)
        
        instructorNameLabel.textColor = ThemeManager.sharedInstance.textColor()
        instructorNameLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        instructorDetailLabel.textColor = ThemeManager.sharedInstance.textColor()
        instructorDetailLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        instructorDescriptionLabel.textColor = ThemeManager.sharedInstance.textColor()
        instructorDescriptionLabel.font = ThemeManager.sharedInstance.defaultFont(14)
        
        let profileIcon = FAKIonIcons.personIcon(withSize: 40)
        instructorProfileImageView.image = profileIcon?.image(with: CGSize(width: 40, height: 40))
        
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        backButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        purchaseButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        purchaseButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(14)
        purchaseButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        
        if let packageName = packageName {
            if SessionManager.sharedInstance.hasPackage(packageName: packageName) {
                purchaseButton.setTitle("Go", for: .normal)
            }
            
            if let package = DataLoader.sharedInstance.package(packageName: packageName) {
                FirebaseService.sharedInstance.retrieveImageAtPath(path: package.imageBGPath) { [unowned self] image in
                    self.backgroundImageView.image = image
                }
            }
        }
        
        packageNameLabel.text = packageName
        instructorNameLabel.text = "Instructor: Alan Sanchez"
        instructorDetailLabel.text = "10th Planet Purple Belt, IBJJF Champion"
        instructorDescriptionLabel.text = "Alan teaches jiujitsu at 10th Planet San Mateo and is an avid competitor, having won gold in tournaments all over the world. Most recently, he won a EBI style tournament in South America. He is a purple belt under Adam \"Big Red\" Sachnoff and likes to focus on the details."
    }

    @IBAction func onPurchaseTap(_ sender: Any) {
        guard let packageName = packageName else {
            return
        }
        SessionManager.sharedInstance.retrieveOrPurchasePackageIfNecessary(packageName: packageName,
                                                                           viewController: self,
                                                                           purchasedHandler: { [unowned self] in
                                                                                print("PARTICLE EFFECTS")
                                                                                self.tableView.reloadData()
                                                                                self.navigateToTechnique(packageName: packageName)
                                                                            },
                                                                           cancelHandler: {
                                                                            print("alert: user canceled transaction")
                                                                            let alert = UIAlertController(title: "Error", message: "Something went wrong with the purchase.", preferredStyle: UIAlertControllerStyle.alert)
                                                                            alert.addAction(UIAlertAction(title: "Ok",
                                                                                                          style: UIAlertActionStyle.default,
                                                                                                          handler: nil))
                                                                            
                                                                            self.present(alert, animated: true, completion: nil)
                                                                            })
        }
    
    @IBAction func onBackTap(_ sender: Any) {
        hero_dismissViewController()
    }
    
    func navigateToTechnique(packageName: String) {
        if let techniqueVC = storyboard?.instantiateViewController(withIdentifier: "CharacterAnimationPickerIdentifier") as? CharacterAnimationPickerViewController {
            techniqueVC.packageName = packageName
            self.navigationController?.pushViewController(techniqueVC, animated: true)
        }
    }
}

extension PackageDetailsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let packageName = packageName {
            return sectionArray[section].rowCount(packageName: packageName)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let packageName = packageName else {
            return UITableViewCell()
        }
        var cell = UITableViewCell()
        let section = sectionArray[indexPath.section]
        if section == .description {
            if let descriptionCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.PackageDescription, for: indexPath) as? PackageDetailsDescriptionTableViewCell {
                if let package = DataLoader.sharedInstance.package(packageName: packageName) {
                    descriptionCell.descriptionLabel.text = package.packageDescription
                }
                cell = descriptionCell
            }
        } else if section == .techniqueSequences {
            if let techniqueCell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.Technique, for: indexPath) as? TechniqueTableCell {
                let technique = DataLoader.sharedInstance.sequencesInPackage(packageName: packageName)[indexPath.row]
                techniqueCell.titleLabel.text = technique.sequenceName
                techniqueCell.descriptionLabel.text = technique.sequenceDescription
                cell = techniqueCell
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionArray[section].sectionHeaderView(tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionArray[section].sectionHeaderHeight(section: section)
    }
}

extension PackageDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
