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
//        streakLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
//        breathStreakLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
//        playCountLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
//        tokenCountLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()

        // Do any additional setup after loading the view.
        if let currentUserData = SessionManager.sharedInstance.currentUserData {
            userNameLabel.text = "Username: \(currentUserData.userName)"
//            streakLabel.text = "\(currentUserData.streakCount) day streak!"
//            breathStreakLabel.text = "\(currentUserData.breathStreakCount) breaths in current streak"
//            playCountLabel.text = "Play Count: \(currentUserData.playCount)"
//            tokenCountLabel.text = "Token Count: \(currentUserData.tokenCount)"
            
        }
        
        collectionView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        collectionView.register(UINib(nibName: "UserStatCollectionCell", bundle: nil), forCellWithReuseIdentifier: UserStatConstants.CellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
//        var myPackages: [AnimationPackage] = []
//        let packages = DataLoader.sharedInstance.packages()
//        for package in packages {
//            let hasPackage = SessionManager.sharedInstance.hasPackage(packageName: package.packageName)
//            if hasPackage {
//                myPackages.append(package)
//                let sequencesInPackage = DataLoader.sharedInstance.sequencesInPackage(packageName: package.packageName)
//            }
//        }
        
//        purchasedPackages = myPackages
//        carousel.dataSource = self
//        carousel.delegate = self
//        carousel.type = .rotary
    }
    
    @IBAction func onLoginTap(_ sender: Any) {
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginVC.viewModel = LoginViewModel()
            present(loginVC, animated: true, completion: nil)
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

extension MeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserStatConstants.CellIdentifier, for: indexPath)
        if let cell = cell as? UserStatCollectionCell {
            
            var title = ""
            var stat = ""
            if let userData = SessionManager.sharedInstance.currentUserData {
                if indexPath.row == 0 {
                    title = "Total"
                    stat = "\(userData.totalBreathCount)"
                } else if indexPath.row == 1 {
                    title = "Current streak"
                    stat = "\(userData.streakCount)"
                } else if indexPath.row == 2 {
                    title = "Current breath streak"
                    stat = "\(userData.breathStreakCount)"
                } else if indexPath.row == 3 {
                    title = "Max day streak"
                    stat = "\(userData.maxDayStreak)"
                } else if indexPath.row == 4 {
                    title = "Max breath streak"
                    stat = "\(userData.maxBreathStreak)"
                }
            }
            
            cell.titleLabel.text = title
            cell.statLabel.text = stat
        }
        return cell
    }
}

// refactor
extension MeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        //2
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = indexPath.row == 0 ? availableWidth : availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
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
