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
    var currentUserData: UserData?
    
    internal var cauliflowerCoins: Int = 0 // lara wrote this
    internal var purchasedPackages: [String: Any] = Dictionary<String, Any>()
    
    
    func onStart() {
        if let currentUser = Auth.auth().currentUser {
            // already signed in
            self.isAnonymous = currentUser.isAnonymous
            onLogin()
            retrieveCurrentUser(userId: currentUser.uid)
        } else {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let user = user {
                    self.isAnonymous = user.isAnonymous
                    self.onLogin()
                    self.retrieveCurrentUser(userId: user.uid)
                }
            })
        }

        
        FirebaseService.sharedInstance.retrieveDB()
        
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    func onPlay() {
        StatManager.sharedIntance.onPlay()
        if let currentUser = Auth.auth().currentUser {
            FirebaseService.sharedInstance.incrementAttributeCount(userId: currentUser.uid, attributeName: "playCount")
        }
    }
    
    func onPlayFinish(breathCount: Int = 0) {
        if let currentUserData = currentUserData {
            let lastPlay = Date(timeIntervalSince1970: currentUserData.lastStreakTimestamp)
            if Calendar.current.isDateInYesterday(lastPlay) {
                FirebaseService.sharedInstance.incrementAttributeCount(userId: currentUserData.userId, attributeName: "streakCount", defaultValue: 1)
                FirebaseService.sharedInstance.incrementAttributeCount(userId: currentUserData.userId, attributeName: "breathStreakCount", count: breathCount)
            } else if Calendar.current.isDateInToday(lastPlay) {
                FirebaseService.sharedInstance.incrementAttributeCount(userId: currentUserData.userId, attributeName: "breathStreakCount", count: breathCount)
            } else if !Calendar.current.isDateInToday(lastPlay) {
                FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId, attributeName: "streakCount", value: 1)
                FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId, attributeName: "breathStreakCount", value: 0)
            }
            FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId, attributeName: "lastStreakTimestamp", value: Date().timeIntervalSince1970)
        }
    }
    
    func onLogin() {
        if let currentUser = Auth.auth().currentUser {
            FirebaseService.sharedInstance.setUserAttribute(userId: currentUser.uid, attributeName: "lastLoggedIn", value: Date().description)
        }
    }
    
    func retrieveCurrentUser(userId: String) {
        FirebaseService.sharedInstance.retrieveUser(userId: userId) { [unowned self] user in
            print(user)
            self.currentUserData = user
        }
    }
    
    // MARK: - Auth
    typealias SignInUserHandler = (_ success: Bool, _ errorMessage: String?) -> Void
    func createUser(userName: String?, email: String?, password: String?, handler: @escaping SignInUserHandler) {
        guard let userName = userName else {
            handler(false, "Please pick a username for your account")
            return
        }
        
        guard let email = email else {
            handler(false, "Please enter your email address")
            return
        }
        
        guard let password = password else {
            handler(false, "Please enter a password with at least 5 characters")
            return
        }
        
        if userName.characters.count < 5 {
            handler(false, "Please enter a username with at least 5 characters")
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: email) {
            handler(false, "Please enter a valid email address (user@example.com)")
            return
        }
        
        if password.characters.count < 5 {
            handler(false, "Please enter a password with at least 5 characters")
            return
        }
        
        // TODO: check for existing username

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        Auth.auth().currentUser?.link(with: credential, completion: { user, error in
            if let error = error {
                print(error.localizedDescription)
                handler(false, error.localizedDescription)
            } else if let user = user {
                FirebaseService.sharedInstance.setUserName(userId: user.uid, userName: userName)
                handler(true, nil)
            }
        })
        // Not used bc we want to convert anonymouse to permanent
//        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
//            print(user)
//            print(error)
//            print("done")
//            if let error = error {
//                handler(false, error.localizedDescription)
//            }
//
//            // TODO: set session user?
//        }
    }
    
    func signIn(email: String?, password: String?, handler: @escaping SignInUserHandler) {
        guard let email = email else {
            handler(false, "Please enter your email address")
            return
        }
        
        guard let password = password else {
            handler(false, "Please enter a password with at least 5 characters")
            return
        }
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if !emailTest.evaluate(with: email) {
            handler(false, "Please enter a valid email address (user@example.com)")
            return
        }
        
        if password.characters.count < 5 {
            handler(false, "Please enter a password with at least 5 characters")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                handler(false, error.localizedDescription)
            } else if let user = user {
                self.retrieveCurrentUser(userId: user.uid)
                FirebaseService.sharedInstance.setUserAttribute(userId: user.uid, attributeName: "lastLoggedIn", value: Date().description)
                handler(true, nil)
            }
        }
    }
    
    func retrieveOrPurchasePackageIfNecessary(packageName: String, viewController: UIViewController, purchasedHandler: @escaping (() -> Void), cancelHandler: @escaping (() -> Void)) {
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
                                            FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId , attributeName: "tokenCount", value: 10)
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
        guard let currentUserData = currentUserData else {
            fatalError("No User logged in ")
        }
        FirebaseService.sharedInstance.purchasePackageAndDecrementToken(userId: currentUserData.userId, packageName: packageName) { success in
            completion(success)
        }
    }
}
