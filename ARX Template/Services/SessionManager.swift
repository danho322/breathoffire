//
//  SessionManager.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/6/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseAnalytics

// Stores the user specific data

class SessionManager {
    static let sharedInstance = SessionManager()
    
    var isAnonymous: Bool?
    var uid: String?
    
    internal var currentUserData: UserData?
    internal var cauliflowerCoins: Int = 0 // lara wrote this
    internal var purchasedPackages: [String: Any] = Dictionary<String, Any>()
    
    
    func onStart() {
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if let user = user {
                self.uid = user.uid
                self.isAnonymous = user.isAnonymous
                
//                FirebaseService.sharedInstance.setUserName(userId: user.uid, userName: "Dan")
                FirebaseService.sharedInstance.retrieveUser(userId: user.uid) { [unowned self] user in
                    print(user)
                    self.currentUserData = user
                }
            }
        })
        
        FirebaseService.sharedInstance.retrieveDB()
        
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    func retrieveOrPurchasePackageIfNecessary(packageName: String, viewController: UIViewController, purchasedHandler: @escaping (() -> Void), cancelHandler: @escaping (() -> Void)) {
        guard let uid = uid else {
            cancelHandler()
            return
        }
        
        guard let currentUserData = currentUserData else {
            cancelHandler()
            return
        }
        
        guard let package = DataLoader.sharedInstance.package(packageName: packageName) else {
            cancelHandler()
            return
        }
        
        if hasPackage(packageName: packageName) {
            purchasedHandler()
            return
        }
        
        if package.tokenCost > currentUserData.tokenCount {
            let alert = UIAlertController(title: "Purchase token", message: "Purchase tokens to unlock \(packageName)?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: UIAlertActionStyle.default,
                                          handler: { alert in
                                            print("purchase tokens here")
                                            FirebaseService.sharedInstance.setUserAttribute(userId: uid , attributeName: "tokenCount", value: 10)
                                            purchasedHandler()
                                            
            }))
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { alert in
                                            cancelHandler()
                                            
            }))
            viewController.present(alert, animated: true, completion: nil)
        } else {
            onPurchasePackage(packageName: packageName) { success in
                if success {
                    purchasedHandler()
                } else {
                    cancelHandler()
                }
            }
        }
    }
    
    func hasPackage(packageName: String) -> Bool {
        guard let currentUserData = currentUserData else {
            return false
        }
        
        return currentUserData.purchasedPackages[packageName] != nil
    }
    
    func onPurchasePackage(packageName: String, completion: @escaping (Bool) -> Void) {
        guard let uid = uid else {
            fatalError("No User logged in ")
        }
        FirebaseService.sharedInstance.purchasePackageAndDecrementToken(userId: uid, packageName: packageName) { success in
            completion(success)
        }
    }
}
