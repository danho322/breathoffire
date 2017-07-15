//
//  SessionManager.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/6/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseAnalytics

class SessionManager {
    static let sharedInstance = SessionManager()
    
    var isAnonymous: Bool?
    var uid: String?
    
    func onStart() {
        Auth.auth().signInAnonymously(completion: { (user, error) in
            if let user = user {
                self.uid = user.uid
                self.isAnonymous = user.isAnonymous
            }
        })
        
        Analytics.logEvent(AnalyticsEventAppOpen, parameters: nil)
    }
}
