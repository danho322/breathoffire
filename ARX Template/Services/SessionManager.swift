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
import CoreLocation

// Stores the user specific data
enum UserAttribute: String {
    case userName = "userName"
    case dayStreakCount = "dayStreakCount"
    case playCount = "playCount"
    case maxDayStreak = "maxDayStreak"
    case maxTimeStreak = "maxTimeStreak"
    case timeStreakCount = "timeStreakCount"
    case totalTimeCount = "totalTimeCount"
    case lastStreakTimestamp = "lastStreakTimestamp"
    case lastLoggedIn = "lastLoggedIn"
    case tokenCount = "tokenCount"
    case city = "city"
    case latitude = "latitude"
    case longitude = "longitude"
    case purchasedPackages = "purchasedPackages"
    
    func attributeValue(userData: UserData) -> Int {
        switch self {
        case .maxDayStreak:
            return userData.maxDayStreak
        case .maxTimeStreak:
            return userData.maxTimeStreak
        case .totalTimeCount:
            return userData.totalTimeCount
        case .playCount:
            return userData.playCount
        case .dayStreakCount:
            return userData.dayStreakCount
        case .timeStreakCount:
            return userData.timeStreakCount
        default:
            return 0
        }
    }
}

struct TutorialInstructionID: OptionSet {
    let rawValue: Int
    
    static let None             = TutorialInstructionID(rawValue: 0)
    static let Walkthrough   = TutorialInstructionID(rawValue: 1 << 0)
    static let Options    = TutorialInstructionID(rawValue: 1 << 1)
    static let ARTechnique = TutorialInstructionID(rawValue: 1 << 2)
}

enum TutorialInstructionType: String {
    case Walkthrough = "kDefaultWalkthrough"
    case Options = "kDefaultOptions"
    case ARTechnique = "kDefaultArtechnique"
    
    func ID() -> TutorialInstructionID {
        switch self {
        case .Walkthrough:
            return TutorialInstructionID.Walkthrough
        case .Options:
            return TutorialInstructionID.Options
        case .ARTechnique:
            return TutorialInstructionID.ARTechnique
        }
    }
}

class SessionManager {
    static let sharedInstance = SessionManager()
    
    var isAnonymous: Bool?
    var currentUserData: UserData?
    
    internal var cauliflowerCoins: Int = 0 // lara wrote this
    internal var purchasedPackages: [String: Any] = Dictionary<String, Any>()
    
    init() {
    
    }
    
    func isCurrentUser(userId: String) -> Bool {
        if let currentUserData = currentUserData {
            return currentUserData.userId == userId
        }
        return false
    }
    
    func onStart() {
        
        let userLoggedInHandler: (UserData)->Void = { _ in
            FirebaseService.sharedInstance.onUserLoggedIn()
        }
        
        if let currentUser = Auth.auth().currentUser {
            // already signed in
            self.isAnonymous = currentUser.isAnonymous
            onLogin()
            retrieveCurrentUser(userId: currentUser.uid, completion: userLoggedInHandler)
        } else {
            Auth.auth().signInAnonymously(completion: { (user, error) in
                if let user = user {
                    self.isAnonymous = user.isAnonymous
                    self.onLogin()
                    self.retrieveCurrentUser(userId: user.uid, completion: userLoggedInHandler)
                }
            })
        }
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
    
    func onPlay() {
        StatManager.sharedIntance.onPlay()
        if let currentUser = Auth.auth().currentUser {
            FirebaseService.sharedInstance.incrementAttributeCount(userId: currentUser.uid, attribute: .playCount)
        }
        Analytics.logEvent("on_play", parameters: nil)
    }
    
    func onPlayFinish(breathTimeInterval: TimeInterval = 0) {
        var attributeContainers: [IncrementAttributeContainer] = []
        
        let breathTime = Int(breathTimeInterval)
        if let currentUserData = currentUserData {
            let lastPlay = Date(timeIntervalSince1970: currentUserData.lastStreakTimestamp)
            if Calendar.current.isDateInYesterday(lastPlay) {
                attributeContainers.append(IncrementAttributeContainer(attribute: .dayStreakCount, count: 1, defaultValue: 1))
                attributeContainers.append(IncrementAttributeContainer(attribute: .timeStreakCount, count: breathTime, defaultValue: 0))
            } else if Calendar.current.isDateInToday(lastPlay) {
                attributeContainers.append(IncrementAttributeContainer(attribute: .timeStreakCount, count: breathTime, defaultValue: 0))
            } else if !Calendar.current.isDateInToday(lastPlay) {
                FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId, attribute: .dayStreakCount, value: 1)
                FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId, attribute: .timeStreakCount, value: breathTime)
            }
            attributeContainers.append(IncrementAttributeContainer(attribute: .totalTimeCount, count: breathTime, defaultValue: 0))
            FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId, attribute: .lastStreakTimestamp, value: Date().timeIntervalSince1970)
            FirebaseService.sharedInstance.incrementAttributeCount(userId: currentUserData.userId, attributeContainers: attributeContainers)
            updateCurrentUser(completion: { currentUser in
                self.updateLongestStreaks(userId: currentUser.userId)
            })
        }
    }
    
    func onLogin() {
        if let currentUser = Auth.auth().currentUser {
            FirebaseService.sharedInstance.setUserAttribute(userId: currentUser.uid, attribute: .lastLoggedIn, value: Date().description)
            
//            var testSession: LiveSession?
//            testSession = LiveSession(userId: currentUser.uid, intention: "This is a test intension")
//            FirebaseService.sharedInstance.saveLiveSession(testSession)
//            FirebaseService.sharedInstance.getCurrentSessions() { session in
//                print("TODO")
//            }
        }
    }
    
    func retrieveCurrentUser(userId: String, completion: ((UserData)->Void)? = nil) {
        FirebaseService.sharedInstance.retrieveUser(userId: userId) { [unowned self] user in
            print(user)
            self.currentUserData = user
            completion?(user)
        }
    }
    
    func updateCurrentUser(completion: ((UserData)->Void)? = nil) {
        if let currentUserData = currentUserData {
            retrieveCurrentUser(userId: currentUserData.userId) { userData in
                completion?(userData)
            }
        }
    }
    
    func updateLongestStreaks(userId: String) {
        retrieveCurrentUser(userId: userId) { userData in
            if userData.timeStreakCount > userData.maxTimeStreak {
                FirebaseService.sharedInstance.setUserAttribute(userId: userId, attribute: UserAttribute.maxTimeStreak, value: userData.timeStreakCount)
            }
            if userData.dayStreakCount > userData.maxDayStreak {
                FirebaseService.sharedInstance.setUserAttribute(userId: userId, attribute: UserAttribute.maxDayStreak, value: userData.dayStreakCount)
            }
        }
    }
    
    // MARK: - Auth
    typealias SignInUserHandler = (_ success: Bool, _ errorMessage: String?) -> Void
    func createUser(userName: String?, email: String?, password: String?, city: String?, coordinate: CLLocationCoordinate2D? = nil, handler: @escaping SignInUserHandler) {
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
                if let coordinate = coordinate {
                    FirebaseService.sharedInstance.setUserAttribute(userId: user.uid, attribute: .latitude, value: coordinate.latitude)
                    FirebaseService.sharedInstance.setUserAttribute(userId: user.uid, attribute: .longitude, value: coordinate.longitude)
                }
                if let city = city {
                    FirebaseService.sharedInstance.setUserAttribute(userId: user.uid, attribute: .city, value: city)
                }
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
                FirebaseService.sharedInstance.setUserAttribute(userId: user.uid, attribute: .lastLoggedIn, value: Date().description)
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
                                            FirebaseService.sharedInstance.setUserAttribute(userId: currentUserData.userId , attribute: .tokenCount, value: 10)
                                            purchasedHandler()
                                            
            }))
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: UIAlertActionStyle.cancel,
                                          handler: { alert in
                                            cancelHandler()
                                            
            }))
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = viewController.view
                popoverPresentationController.sourceRect = viewController.view.bounds
            }
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
    
    // MARK: - Login
    
    internal var hasShownUpsellLogin = false
    
    func shouldShowUpsellLogin() -> Bool {
        let isAnonymous = SessionManager.sharedInstance.isAnonymous ?? true
        if !hasShownUpsellLogin && isAnonymous {
            hasShownUpsellLogin = true
            return true
        }
        return false
    }
    
    func presentLogin(on viewController: UIViewController, completion: @escaping ()->Void) {
        if let loginVC = viewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginVC.viewModel = LoginViewModel()
            loginVC.completion = completion
            viewController.present(loginVC, animated: true, completion: nil)
        }
    }
    
    // MARK: - Tutorials
    var tutorialStoredValue: Int {
        set {
            UserDefaults.standard.set(newValue, for: .tutorialFlag)
        }
        get {
            return UserDefaults.standard.integer(for: .tutorialFlag)
        }
    }
    
    func shouldShowTutorial(type: TutorialInstructionType) -> Bool {
        let setFlags = TutorialInstructionID(rawValue: tutorialStoredValue)
        return !setFlags.contains(type.ID())
    }
    
    func onTutorialShow(type: TutorialInstructionType) {
        var tutorialOptions = TutorialInstructionID(rawValue: tutorialStoredValue)
        tutorialOptions.insert(type.ID())
        tutorialStoredValue = tutorialOptions.rawValue
    }
}
