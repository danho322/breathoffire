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
    @IBOutlet weak var playCountLabel: UILabel!
    @IBOutlet weak var tokenCountLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let currentUserData = SessionManager.sharedInstance.currentUserData {
            userNameLabel.text = currentUserData.userName
            playCountLabel.text = "\(currentUserData.playCount)"
            tokenCountLabel.text = "\(currentUserData.tokenCount)"
            
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
    }
}
