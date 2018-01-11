//
//  ThemeManager.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/18/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

struct ThemeManager {
    static let sharedInstance = ThemeManager()
    
    func backgroundView(frame: CGRect) -> CALayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [backgroundColor().cgColor, focusColor().cgColor]
        gradientLayer.locations = [ 0.0, 1.0]
        return gradientLayer
    }
    
    func backgroundColor(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: 46 / 255.0, green: 42 / 255.0, blue: 70 / 255.0, alpha: alpha)
    }
    
    func feedBackgroundColor() -> UIColor {
        return ThemeManager.sharedInstance.backgroundColor()
    }
    
    func feedTextColor() -> UIColor {
        return UIColor.black
    }
    
    func foregroundColor() -> UIColor {
        return UIColor(red: 68 / 255.0, green: 61 / 255.0, blue: 101 / 255.0, alpha: 1)
    }
    
    func focusColor() -> UIColor {
        return UIColor(red: 92 / 255.0, green: 179 / 255.0, blue: 126 / 255.0, alpha: 1)
    }
    
    func focusForegroundColor() -> UIColor {
        return UIColor.white
    }
    
    func secondaryFocusForegroundColor() -> UIColor {
        return UIColor(red: 241 / 255.0, green: 241 / 255.0, blue: 241 / 255.0, alpha: 1)
    }
    
    func errorTextColor() -> UIColor {
        return UIColor.red
    }
    
    func labelTitleColor() -> UIColor {
        return UIColor(red: 152 / 255.0, green: 138 / 255.0, blue: 178 / 255.0, alpha: 1)
    }
    
    func textColor() -> UIColor {
        return UIColor(red: 244 / 255.0, green: 246 / 255.0, blue: 248 / 255.0, alpha: 1)
    }
    
    func iconColor() -> UIColor {
        return UIColor(red: 109 / 255.0, green: 181 / 255.0, blue: 231 / 255.0, alpha: 1)
    }
    
    func defaultFont(_ size: CGFloat) -> UIFont {
//        let fontFamilyNames = UIFont.familyNames
//        for familyName in fontFamilyNames {
//            print("------------------------------")
//            print("Font Family Name = [\(familyName)]")
//            let names = UIFont.fontNames(forFamilyName: familyName)
//            print("Font Names = [\(names)]")
//        }
        
        return UIFont(name: "AvenirNext-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    func heavyFont(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNext-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
    
    func formatSearchBar(_ searchBar: UISearchBar) {
        UIBarButtonItem.appearance(whenContainedInInstancesOf:[UISearchBar.self]).tintColor = focusForegroundColor()

        searchBar.barTintColor = foregroundColor()
        searchBar.backgroundColor = backgroundColor()
        searchBar.tintColor = focusForegroundColor()
    }
}
