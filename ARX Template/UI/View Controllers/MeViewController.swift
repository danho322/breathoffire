//
//  MeViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class MeViewController: UIViewController {
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var breathStreakLabel: UILabel!
    @IBOutlet weak var tokenCountLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        for subview in scrollView.subviews {
            subview.removeFromSuperview()
        }
        
        var myPackages: [AnimationPackage] = []
        let packages = DataLoader.sharedInstance.packages()
        for package in packages {
            let hasPackage = SessionManager.sharedInstance.hasPackage(packageName: package.packageName)
            if hasPackage {
                myPackages.append(package)
                let sequencesInPackage = DataLoader.sharedInstance.sequencesInPackage(packageName: package.packageName)
                print(sequencesInPackage)
            }
        }
        
        let width: CGFloat = 200
        var x: CGFloat = 15
        for package in myPackages {
            let packageLabel = UILabel(frame: CGRect(x: x, y: 0, width: width, height: scrollView.frame.size.height))
            packageLabel.textColor = ThemeManager.sharedInstance.textColor()
            packageLabel.text = package.packageName
//            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPackageLabelTap(gesture:)))
//            packageLabel.addGestureRecognizer(tapGesture)
            packageLabel.isUserInteractionEnabled = true
            scrollView.addSubview(packageLabel)
            x += width + 10
        }
        scrollView.contentSize = CGSize(width: x, height: scrollView.frame.size.height)
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
}
