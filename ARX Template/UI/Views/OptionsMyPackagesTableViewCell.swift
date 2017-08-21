//
//  OptionsPackagesTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/22/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import iCarousel

class OptionsMyPackagesTableViewCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var carousel: iCarousel!
    internal var purchasedPackages: [AnimationPackage] = []

    
    internal var packageTapHandler: ((String?) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cardView.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
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
    }
    
    @objc internal func onPackageLabelTap(gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel {
            packageTapHandler?(label.text)
        }
    }
    
    func handlePackageTap(packageName: String?) {
         packageTapHandler?(packageName)
    }
}

extension OptionsMyPackagesTableViewCell: iCarouselDelegate {
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        handlePackageTap(packageName: purchasedPackages[index].packageName)
    }
}

extension OptionsMyPackagesTableViewCell: iCarouselDataSource {
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
