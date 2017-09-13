//
//  MeViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import iCarousel

class MeViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    internal var purchasedPackages: [AnimationPackage] = []
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        userNameLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()

        // Do any additional setup after loading the view.
        if let currentUserData = SessionManager.sharedInstance.currentUserData {
            userNameLabel.text = "Username: \(currentUserData.userName)"
        }
        
        let isAnonymous = SessionManager.sharedInstance.isAnonymous ?? true
        loginButton.setTitle("Sign into your account", for: .normal)
        loginButton.isHidden = !isAnonymous
        
        collectionView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        collectionView.register(UINib(nibName: String(describing: UserStatCollectionCell.self), bundle: nil), forCellWithReuseIdentifier: UserStatConstants.CellIdentifier)
        collectionView.register(UINib(nibName: String(describing: UserPackagesCollectionCell.self), bundle: nil), forCellWithReuseIdentifier: UserPackageCellConstants.CellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        var myPackages: [AnimationPackage] = []
        let packages = DataLoader.sharedInstance.packages()
        for package in packages {
            let hasPackage = SessionManager.sharedInstance.hasPackage(packageName: package.packageName)
            if hasPackage {
                myPackages.append(package)
                let sequencesInPackage = DataLoader.sharedInstance.sequencesInPackage(packageName: package.packageName)
            }
        }

        purchasedPackages = myPackages
    }
    
    @IBAction func onLoginTap(_ sender: Any) {
        if SessionManager.sharedInstance.isAnonymous ?? true {
            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.viewModel = LoginViewModel()
                loginVC.completion = { [unowned self] in
                    self.collectionView.reloadData()
                }
                present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    func handlePackageTap(packageName: String?) {
        if let techniqueVC = storyboard?.instantiateViewController(withIdentifier: "CharacterAnimationPickerIdentifier") as? CharacterAnimationPickerViewController {
            techniqueVC.packageName = packageName
            navigationController?.pushViewController(techniqueVC, animated: true)
        }
    }
}

extension MeViewController: iCarouselDelegate {
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        handlePackageTap(packageName: purchasedPackages[index].packageName)
    }
}

extension MeViewController: iCarouselDataSource {
    func numberOfItems(in carousel: iCarousel) -> Int {
        return purchasedPackages.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //reuse view if available, otherwise create a new view
        if let view = view as? UIImageView {
            itemView = view
            //get a reference to the label in the recycled view
            label = itemView.viewWithTag(1) as! UILabel
        } else {
            //don't do anything specific to the index within
            //this `if ... else` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            FirebaseService.sharedInstance.retrieveImageAtPath(path: purchasedPackages[index].imageBGPath) { image in
                itemView.image = image
            }
            itemView.contentMode = .scaleAspectFill
            itemView.layer.masksToBounds = true
            
            label = UILabel(frame: itemView.bounds)
            label.textColor = ThemeManager.sharedInstance.focusForegroundColor()
            label.backgroundColor = .clear
            label.numberOfLines = 0
            label.lineBreakMode = .byWordWrapping
            label.textAlignment = .center
            label.font = ThemeManager.sharedInstance.heavyFont(24)
            label.tag = 1
            itemView.addSubview(label)
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "\(purchasedPackages[index].packageName)"
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .spacing) {
            return value * 1.1
        }
        return value
    }
}

extension MeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

enum StatType: Int {
    case totalTime = 0
    case currentDayStreak = 1
    case currentTimeStreak = 2
    case maxDayStreak = 3
    case maxTimeStreak = 4
    case packages = 5
    case count = 6
    
    func title() -> String {
        switch self {
        case .totalTime:
            return "Total Time Breathed"
        case .currentDayStreak:
            return "Current Day Streak"
        case .currentTimeStreak:
            return "Current Time Streak"
        case .maxDayStreak:
            return "Max Day Streak"
        case .maxTimeStreak:
            return "Max Time Streak"
        default:
            return ""
        }
    }
    
    func statString(userData: UserData) -> String {
        switch self {
        case .totalTime:
            return "\(userData.totalTimeCount)"
        case .currentDayStreak:
            return "\(userData.dayStreakCount)"
        case .currentTimeStreak:
            return "\(userData.timeStreakCount)"
        case .maxDayStreak:
            return "\(userData.maxDayStreak)"
        case .maxTimeStreak:
            return "\(userData.maxTimeStreak)"
        default:
            return ""
        }
    }
    
    func cellIdentifier() -> String {
        if self == .packages {
            return UserPackageCellConstants.CellIdentifier
        }
        return UserStatConstants.CellIdentifier
    }
}

extension MeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StatType.count.rawValue
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let statType = StatType(rawValue: indexPath.row) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: statType.cellIdentifier(), for: indexPath)
            if let cell = cell as? UserStatCollectionCell {
                
                var title = ""
                var stat = ""
                if let userData = SessionManager.sharedInstance.currentUserData {
                    title = statType.title()
                    stat = statType.statString(userData: userData)
                }
                
                cell.titleLabel.text = title
                cell.statLabel.text = stat
            } else if let cell = cell as? UserPackagesCollectionCell {
                cell.carousel.dataSource = self
                cell.carousel.delegate = self
                cell.carousel.type = .rotary

            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// refactor
extension MeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        if indexPath.row != StatType.packages.rawValue {
            let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
            let availableWidth = view.frame.width - paddingSpace
            let widthPerItem = indexPath.row == 0 ? availableWidth : availableWidth / itemsPerRow
            let heightPerItem = availableWidth / itemsPerRow
            
            return CGSize(width: widthPerItem, height: heightPerItem)
        }
        return CGSize(width: view.frame.width, height: 200)
    }

    //3
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }

    // 4
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
