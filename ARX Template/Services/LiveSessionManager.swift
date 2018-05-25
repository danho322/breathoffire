//
//  LiveSessionManager.swift
//  ARX Template
//
//  Created by Daniel Ho on 12/12/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation

protocol LiveSessionDelegate {
    func onUserJoined(userName: String, userCount: Int)
}

class LiveSessionManager {
    static let sharedInstance = LiveSessionManager()
    
    func currentSessions(sessionHandler: @escaping ([LiveSession])->Void) {
        let completion: ([LiveSession])->Void = { sessions in
            var sessionsToReturn = sessions
            if let currentUserId = SessionManager.sharedInstance.currentUserData?.userId {
                sessionsToReturn = sessionsToReturn.filter({ $0.creatorUserId != currentUserId })
            }
            sessionHandler(sessionsToReturn)
        }
        FirebaseService.sharedInstance.getCurrentSessions(sessionHandler: completion)
    }

    // MARK: - Live Session Creator
    // creates a room
    // pings the room timestamp during session
    func startLiveSession(intention: String, sequenceName: String, delegate: LiveSessionDelegate) -> String? {
        var currentKey: String?
        if let user = SessionManager.sharedInstance.currentUserData {
            let newLiveSession = LiveSession(userId: user.userId, userName: user.userName, intention: intention, sequenceName: sequenceName)
            currentKey = FirebaseService.sharedInstance.saveLiveSession(newLiveSession)
            addUserToLiveSession(key: currentKey, userName: user.userName)
            incrementLiveSessionStat(key: currentKey)
            listenToUserCount(key: currentKey, delegate: delegate)
        }
        return currentKey
    }
    
    // joins a room
    // pings the room timestamp during session
    func joinLiveSession(key: String, delegate: LiveSessionDelegate) {
        if let user = SessionManager.sharedInstance.currentUserData {
            addUserToLiveSession(key: key, userName: user.userName)
        }
        incrementLiveSessionStat(key: key)
        listenToUserCount(key: key, delegate: delegate)
    }
    
    func pingCurrentLiveSession(key: String?) {
        FirebaseService.sharedInstance.pingCurrentLiveSession(key: key)
    }
    
    // MARK: - Helpers
    
    func addUserToLiveSession(key: String?, userName: String) {
        if let key = key {
            // add user to list
            FirebaseService.sharedInstance.addLiveSessionUserList(key: key, userName: userName)
            // get list count
            var removeObserverBlock: (()->Void)?
            removeObserverBlock = FirebaseService.sharedInstance.listenLiveSessionUserList(key: key, eventType: .value, listHandler: { nameSet in
                FirebaseService.sharedInstance.updateLiveSessionUserCount(key: key, count: nameSet.count)
                removeObserverBlock?()
            })
        }
    }
    
    func incrementLiveSessionStat(key: String?) {
        
    }
    
    var prevSet: Set<String> = Set<String>()
    func listenToUserCount(key: String?, delegate: LiveSessionDelegate) {
        var currentUser = ""
        if let user = SessionManager.sharedInstance.currentUserData {
            currentUser = user.userName
        }
        if let key = key {
            _ = FirebaseService.sharedInstance.listenLiveSessionUserList(key: key, eventType: .value, listHandler: { nameSet in
                let newUsers = nameSet.subtracting(self.prevSet)
                // new users is the newly joined
                for user in newUsers {
                    if currentUser != user {
                        delegate.onUserJoined(userName: user, userCount: nameSet.count)
                    }
                }
                self.prevSet = newUsers
            })
        }
    }
}

enum LiveSessionType {
    case none, create, join
}

struct LiveSessionInfo {
    let type: LiveSessionType
    let liveSession: LiveSession?
    let intention: String?
}

struct LiveSession {
    static let PingTimestampKey = "pingTimestamp"
    static let PingFrequency: TimeInterval = 30
    
    let key: String
    let creatorUserId: String
    let userName: String
    let startTimestamp: TimeInterval
    let pingTimestamp: TimeInterval
    let intention: String
    let userCount: Int
    let sequenceName: String
    
    init(userId: String, userName: String, intention: String, sequenceName: String) {
        key = ""
        startTimestamp = Date().timeIntervalSince1970
        pingTimestamp = Date().timeIntervalSince1970
        userCount = 0
        creatorUserId = userId
        self.userName = userName
        self.intention = intention
        self.sequenceName = sequenceName
    }
    
    init(key: String, snapshotDict: NSDictionary) {
        self.key = key
        creatorUserId = snapshotDict["creatorUserId"] as? String ?? ""
        userName = snapshotDict["userName"] as? String ?? ""
        startTimestamp = snapshotDict["startTimestamp"] as? TimeInterval ?? 0
        pingTimestamp = snapshotDict["pingTimestamp"] as? TimeInterval ?? 0
        intention = snapshotDict["intention"] as? String ?? ""
        userCount = snapshotDict["userCount"] as? Int ?? 0
        sequenceName = snapshotDict["sequenceName"] as? String ?? ""
    }
    
    func valueDict() -> [String: Any] {
        let dict: [String: Any] = ["creatorUserId": creatorUserId,
                                   "userName": userName,
                                   "startTimestamp": Int(startTimestamp),
                                   "pingTimestamp": Int(pingTimestamp),
                                   "intention": intention,
                                   "userCount": userCount,
                                   "sequenceName": sequenceName]
        return dict
    }
}
