//
//  OptionsPackagesTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class OptionsMyPackagesTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    internal var packageTapHandler: ((String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(packageTapHandler: @escaping ((String?) -> Void)) {
        self.packageTapHandler = packageTapHandler
        
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
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onPackageLabelTap(gesture:)))
            packageLabel.addGestureRecognizer(tapGesture)
            packageLabel.isUserInteractionEnabled = true
            scrollView.addSubview(packageLabel)
            x += width + 10
        }
        scrollView.contentSize = CGSize(width: x, height: scrollView.frame.size.height)
    }
    
    @objc internal func onPackageLabelTap(gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel {
            packageTapHandler?(label.text)
        }
    }
}
