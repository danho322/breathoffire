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
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var breathStreakLabel: UILabel!
    @IBOutlet weak var tokenCountLabel: UILabel!
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var loginButton: UIButton!
    
    internal var purchasedPackages: [AnimationPackage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        userNameLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        streakLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        breathStreakLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        playCountLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        tokenCountLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()

        // Do any additional setup after loading the view.
        if let currentUserData = SessionManager.sharedInstance.currentUserData {
            userNameLabel.text = "Username: \(currentUserData.userName)"
            streakLabel.text = "\(currentUserData.streakCount) day streak!"
            breathStreakLabel.text = "\(currentUserData.breathStreakCount) breaths in current streak"
            playCountLabel.text = "Play Count: \(currentUserData.playCount)"
            tokenCountLabel.text = "Token Count: \(currentUserData.tokenCount)"
            
        }
        
        var myPackages: [AnimationPackage] = []
        let packages = DataLoader.sharedInstance.packages()
        for package in packages {
            let hasPackage = SessionManager.sharedInstance.hasPackage(packageName: package.packageName)
            if hasPackage {
                myPackages.append(package)
//                let sequencesInPackage = DataLoader.sharedInstance.sequencesInPackage(packageName: package.packageName)
            }
        }
        
        purchasedPackages = myPackages
        carousel.dataSource = self
        carousel.delegate = self
        carousel.type = .rotary
//        iCarouselTypeLinear = 0,
//        iCarouselTypeRotary,
//        iCarouselTypeInvertedRotary,
//        iCarouselTypeCylinder,
//        iCarouselTypeInvertedCylinder,
//        iCarouselTypeWheel,
//        iCarouselTypeInvertedWheel,
//        iCarouselTypeCoverFlow,
//        iCarouselTypeCoverFlow2,
//        iCarouselTypeTimeMachine,
//        iCarouselTypeInvertedTimeMachine,
    }
    
    @IBAction func onLoginTap(_ sender: Any) {
        let loginView = LoginView(frame: CGRect(x: 0, y: 0, width: Sizes.ScreenWidth, height: Sizes.ScreenHeight))
        loginView.completionHandler = {
            // refresh?
        }
        loginView.center = CGPoint(x: view.frame.size.width / 2, y: view.frame.height / 2)
        view.addSubview(loginView)
        loginView.animateIn()
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
