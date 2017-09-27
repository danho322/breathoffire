//
//  FirebaseService.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/7/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import FirebaseDatabase
import FirebaseAnalytics
import FirebaseStorage
import FirebaseAuth
import UIKit
import MapKit
import Gzip

struct Constants {
    static let AppKey = "jiujitsu"
}

// This class stores the remote app data

struct UserData {
    let userId: String
    let userName: String
    let coordinate: CLLocationCoordinate2D?
    let city: String?
    let tokenCount: Int

    // all time
    let playCount: Int
    let maxDayStreak: Int
    let maxTimeStreak: Int
    let totalTimeCount: Int
    
    // current streak
    let dayStreakCount: Int
    let timeStreakCount: Int
    let lastStreakTimestamp: TimeInterval

    let purchasedPackages: [String: Any]
    
    init(userId: String, snapshotDict: NSDictionary) {
        self.userId = userId
        userName = snapshotDict[UserAttribute.userName.rawValue] as? String ?? "Anonymous"
        tokenCount = snapshotDict[UserAttribute.tokenCount.rawValue] as? Int ?? 0
        playCount = snapshotDict[UserAttribute.playCount.rawValue] as? Int ?? 0
        maxDayStreak = snapshotDict[UserAttribute.maxDayStreak.rawValue] as? Int ?? 0
        maxTimeStreak = snapshotDict[UserAttribute.maxTimeStreak.rawValue] as? Int ?? 0
        dayStreakCount = snapshotDict[UserAttribute.dayStreakCount.rawValue] as? Int ?? 0
        timeStreakCount = snapshotDict[UserAttribute.timeStreakCount.rawValue] as? Int ?? 0
        totalTimeCount = snapshotDict[UserAttribute.totalTimeCount.rawValue] as? Int ?? 0
        lastStreakTimestamp = snapshotDict[UserAttribute.lastStreakTimestamp.rawValue] as? TimeInterval ?? 0
        if let packagesDict = snapshotDict[UserAttribute.purchasedPackages.rawValue] as? [String: Any] {
            purchasedPackages = packagesDict
        } else {
            purchasedPackages = Dictionary<String, Any>()
        }
        if let latitude = snapshotDict[UserAttribute.latitude.rawValue] as? CLLocationDegrees,
            let longitude = snapshotDict[UserAttribute.longitude.rawValue] as? CLLocationDegrees {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = nil
        }
        if let city = snapshotDict[UserAttribute.city.rawValue] as? String {
            self.city = city
        } else {
            city = nil
        }
    }
    
    func hasMinimumAttribute(_ attribute: UserAttribute) -> Bool {
        switch attribute {
        case .maxTimeStreak:
            return maxTimeStreak > 0
        case .maxDayStreak:
            return maxDayStreak > 0
        case .totalTimeCount:
            return totalTimeCount > 0
        default:
            return false
        }
    }
}

struct IncrementAttributeContainer {
    let attribute: UserAttribute
    let count: Int
    let defaultValue: Int
}

class FirebaseService: NSObject {
    static let sharedInstance = FirebaseService()
    
    var sectionRefs: [String: DatabaseReference] = Dictionary()
    var sequenceRefs: [String: DatabaseReference] = Dictionary()
    var animationRefs: [String: DatabaseReference] = Dictionary()
    var instructionRefs: [String: DatabaseReference] = Dictionary()
    
    var animationPackages: [AnimationPackage] = []
    var sequenceSections: [String] = []
    var sequenceRows: [String: [String]] = Dictionary()
    var sequenceDataDict: [String: AnimationSequenceDataContainer] = Dictionary()
    var animationDataDict: [String: CharacterAnimationData] = Dictionary()
    var instructionDataDict: [String: [AnimationInstructionData]] = Dictionary()
    
    var motivationQuotes: [String] = []
    
    override init() {
        super.init()
        
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        retrieveDB()
        retrieveMotivation()
    }
    
    // MARK: - Realtime DB
    
    func retrieveUser(userId: String, handler: @escaping ((UserData) -> Void)) {
        let userRef = Database.database().reference().child("users/\(Constants.AppKey)/\(userId)")
        userRef.observe(.value, with: { snapshot in
            if let userDict = snapshot.value as? NSDictionary {
                handler(UserData(userId: userId, snapshotDict: userDict))
            }
        })
    }
    
    func setUserName(userId: String, userName: String) {
        let userRef = Database.database().reference().child("users/\(Constants.AppKey)/\(userId)")
        
        userRef.child("userName").setValue(userName)
    }
    
    func setUserAttribute(userId: String, attribute: UserAttribute, value: Any) {
        let userRef = Database.database().reference().child("users/\(Constants.AppKey)/\(userId)")
        
        userRef.child(attribute.rawValue).setValue(value)
    }
    
    func purchasePackageAndDecrementToken(userId: String, packageName: String, completed: @escaping ((Bool) -> Void)) {
        let ref = Database.database().reference().child("users/\(Constants.AppKey)/\(userId)")
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var user = currentData.value as? [String : AnyObject] {
                var packageDict = user[UserAttribute.purchasedPackages.rawValue] as? [String: Any] ?? Dictionary<String, Any>()
                packageDict[packageName] = 1
                user[UserAttribute.purchasedPackages.rawValue] = packageDict as AnyObject?
                
                var tokenCount = user[UserAttribute.tokenCount.rawValue] as? Int ?? 0
                tokenCount -= 1
                tokenCount = tokenCount >= 0 ? tokenCount : 0
                user[UserAttribute.tokenCount.rawValue] = tokenCount as AnyObject?
                
                // Set value and report transaction success
                currentData.value = user
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            completed(committed)
        }
    }
    
    func incrementAttributeCount(userId: String, attribute: UserAttribute? = nil, count: Int = 1, defaultValue: Int = 0, attributeContainers: [IncrementAttributeContainer] = []) {
        var containers = attributeContainers
        if let attribute = attribute {
            containers.append(IncrementAttributeContainer(attribute: attribute, count: count, defaultValue: defaultValue))
        }
        
        let ref = Database.database().reference().child("users/\(Constants.AppKey)/\(userId)")
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var userDict = currentData.value as? [String : AnyObject] {
                
                for attributeContainer in containers {
                    let defaultValue = attributeContainer.defaultValue
                    let attribute = attributeContainer.attribute
                    let count = attributeContainer.count
                    var attributeCount = userDict[attribute.rawValue] as? Int ?? defaultValue
                    attributeCount += count
                    userDict[attribute.rawValue] = attributeCount as AnyObject?
                }
                
                // Set value and report transaction success
                currentData.value = userDict
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func decrementAttributeCount(userId: String, attribute: UserAttribute) {
        let ref = Database.database().reference().child("users/\(Constants.AppKey)/\(userId)")
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject] {
                var starCount = post[attribute.rawValue] as? Int ?? 0
                starCount -= 1
                starCount = starCount >= 0 ? starCount : 0
                post[attribute.rawValue] = starCount as AnyObject?
                
                // Set value and report transaction success
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Motivation
    
    func retrieveMotivationOfTheDay(completionHandler: @escaping ((String)->Void)) {
        let dayCount = Date().timeIntervalSince1970 / (60 * 60 * 24)
        let count = motivationQuotes.count
        if count > 0 {
            let quote = motivationQuotes[Int(dayCount + 1) % Int(count)]
            completionHandler(quote)
        } else {
            retrieveMotivation() { [unowned self] in
                self.retrieveMotivationOfTheDay(completionHandler: completionHandler)
            }
        }
    }
    
    func retrieveMotivation(completion: (()->Void)? = nil) {
        let ref = Database.database().reference().child("motivationQuotes")
        ref.observe(.value, with: { [unowned self] snapshot in
            var quotes: [String] = []
            if let motivationArray = snapshot.value as? NSArray {
                for motivation in motivationArray {
                    if let motivation = motivation as? String {
                        print(motivation)
                        quotes.append(motivation)
                    }
                }
            }
            self.motivationQuotes = quotes
            completion?()
        })
    }
    
    // MARK: - High Score
    
    func retrieveCurrentTimeStreaks(completionHandler: @escaping (([UserData])->Void)) {
        let startTime = Date().timeIntervalSince1970 - 60 * 60 * 24 // past 24 hours
        let ref = Database.database().reference().child("users/\(Constants.AppKey)")
        ref.queryOrdered(byChild: UserAttribute.lastStreakTimestamp.rawValue)
            .queryStarting(atValue: startTime)
            .queryLimited(toLast: 10)
            .observeSingleEvent(of: .value, with: { snapshot in
                var items: [UserData] = []
                if let userDict = snapshot.value as? NSDictionary {
                    for (key, userDataDict) in userDict {
                        if let userDataDict = userDataDict as? NSDictionary,
                            let key = key as? String {
                            let userData = UserData(userId: key, snapshotDict: userDataDict)
                            if userData.timeStreakCount > 0 {
                                items.append(userData)
                            }
                        }
                    }
                }
                completionHandler(items.sorted(by: { $0.timeStreakCount > $1.timeStreakCount }))
            })
    }
    
    func retrieveMaxAttributes(attribute: UserAttribute, completionHandler: @escaping (([UserData])->Void)) {
        let ref = Database.database().reference().child("users/\(Constants.AppKey)")
        ref.queryOrdered(byChild: attribute.rawValue)
            .queryLimited(toLast: 10)
            .observeSingleEvent(of: .value, with: { snapshot in
                var items: [UserData] = []
                if let userDict = snapshot.value as? NSDictionary {
                    for (key, userDataDict) in userDict {
                        if let userDataDict = userDataDict as? NSDictionary,
                            let key = key as? String {
                            let userData = UserData(userId: key, snapshotDict: userDataDict)
                            if userData.hasMinimumAttribute(attribute) {
                                items.append(userData)
                            }
                        }
                    }
                }
                completionHandler(items)
            })
    }
    
    // MARK: - Feed
    
    func saveBreathFeedItem(_ feedItem: BreathFeedItem) {
        let ref = Database.database().reference().child("feed/\(Constants.AppKey)/\(UUID().uuidString)")
        ref.setValue(feedItem.valueDict())
    }
    
    func retrieveBreathFeed(allowedUpdates: Int, completionHandler: @escaping (([BreathFeedItem])->Void)) {
        var count = 0
        let ref = Database.database().reference().child("feed/\(Constants.AppKey)")
        var handle: UInt?
        handle = ref.queryOrdered(byChild: "timestamp")
            .queryLimited(toFirst: 50)
            .observe(.value, with: { [unowned self] snapshot in
                var items: [BreathFeedItem] = []
                if let feedDict = snapshot.value as? NSDictionary {
                    for (key, feedItemDict) in feedDict {
                        if let feedItemDict = feedItemDict as? NSDictionary {
                            let feedItem = BreathFeedItem(key: key as? String, snapshotDict: feedItemDict)
                            if feedItem.isInappropriate == 0 {
                                items.append(feedItem)
                            }
                        }
                    }
                    count += 1
                    if count == allowedUpdates {
                        if let handle = handle {
                            ref.removeObserver(withHandle: handle)
                        }
                    }
                }
                completionHandler(items.sorted(by: { $0.timestamp > $1.timestamp }))
        })
    }
    
    func deleteFeedItem(feedItem: BreathFeedItem) {
        if let key = feedItem.key {
            let ref = Database.database().reference().child("feed/\(Constants.AppKey)/\(key)")
            ref.removeValue()
            
            for imagePath in feedItem.imagePathArray {
                let imageRef = Storage.storage().reference().child(imagePath)
                imageRef.delete(completion: { error in
                    print("Error deleting file: \(error)")
                })
            }
        }
    }
    
    func markInappropriate(feedItem: BreathFeedItem) {
        if let key = feedItem.key {
            let ref = Database.database().reference().child("feed/\(Constants.AppKey)/\(key)")
            ref.child("inappropriate").setValue(1)
        }
    }
    
    // MARK: - Image loading
    
    func retrieveImageAtPath(path: String, completion: @escaping (UIImage) -> Void) {
        self.downloadFileIfNecessary(path: path) {
            if let image = UIImage(contentsOfFile: "\(self.getDocumentsDirectory())/\(path)") {
                completion(image)
            }
        }
    }
    
    func retrieveDataAtPath(path: String, completion: @escaping (Data) -> Void) {
        self.downloadFileIfNecessary(path: path) {
            if let data = try? NSData(contentsOfFile: "\(self.getDocumentsDirectory())/\(path)") as Data {
                // gunzip
                let decompressedData: Data
                if data.isGzipped {
                    decompressedData = try! data.gunzipped()
                } else {
                    decompressedData = data
                }
                completion(decompressedData)
            }
        }
    }
    
    func retrieveBackgroundImage(completion: @escaping (UIImage) -> Void) {
        let sectionNamesRef = Database.database().reference().child("config/\(Constants.AppKey)/menuBackgroundImage")
        sectionNamesRef.observeSingleEvent(of: .value, with: { [unowned self] snapshot in
            if let path = snapshot.value as? String {
                self.downloadFileIfNecessary(path: path) {
                    if let image = UIImage(contentsOfFile: "\(self.getDocumentsDirectory())/\(path)") {
                        completion(image)
                    }
                }
            }
        })
    }
    
    // MARK: - DB Syncing
    
    func retrieveDB() {
        let sectionNamesRef = Database.database().reference().child("sequenceListSections/\(Constants.AppKey)")
        sectionNamesRef.observe(.value, with: { [unowned self] snapshot in
            self.sequenceSections.removeAll()
            if let sectionSequenceArray = snapshot.value as? NSArray {
                for sectionSequence in sectionSequenceArray {
                    if let sectionString = sectionSequence as? String {
                        self.retrieveSection(sectionSequence: sectionString)
                        self.sequenceSections.append(sectionString)
                    }
                }
            }
        })
        
        let packagesRef = Database.database().reference().child("animationPackages/\(Constants.AppKey)")
        packagesRef.observe(.value, with: { [unowned self] snapshot in
            self.animationPackages.removeAll()
            if let animationPackagesArray = snapshot.value as? NSArray {
                for animationPackage in animationPackagesArray {
                    if let animationPackage = animationPackage as? NSDictionary {
                        let package = AnimationPackage(snapshotDict: animationPackage)
                        if package.packageName.characters.count > 0 {
                            self.animationPackages.append(package)
                        }
                    }
                }
            }
        })
        
//        retrieveAllSequenceData()
    }
    
    internal func retrieveSection(sectionSequence: String) {
        if sectionRefs[sectionSequence] == nil {
            let sectionSequenceRef = Database.database().reference().child("sectionDataSequences/\(sectionSequence)")
            sectionSequenceRef.observe(.value, with: { [unowned self] snapshot in
                if let sequenceDataNameArray = snapshot.value as? NSArray {
                    var sequenceList: [String] = []
                    for sequenceDataName in sequenceDataNameArray {
                        if let sequenceDataName = sequenceDataName as? String {
                            self.retrieveSequenceData(sequenceName: sequenceDataName)
                            sequenceList.append(sequenceDataName)
                        }
                    }
                    self.sequenceRows[sectionSequence] = sequenceList
                }
            })
            sectionRefs[sectionSequence] = sectionSequenceRef
        }
    }
    
    // all sequences must be in sequence list data to be organized correctly
//    internal func retrieveAllSequenceData() {
//        let sequenceDataRef = Database.database().reference().child("sequenceData")
//        sequenceDataRef.observe(.value, with: { [unowned self] snapshot in
//            if let dict = snapshot.value as? NSDictionary {
//                for (sequenceName, sequenceDataDict) in dict {
//                    if let sequenceName = sequenceName as? String,
//                        let sequenceDataDict = sequenceDataDict as? NSDictionary {
//                        let sequence = AnimationSequenceDataContainer(sequenceName: sequenceName, snapshotDict: sequenceDataDict)
//                        self.retrieveAnimationDataFromSequenceData(sequenceDataContainer: sequence)
//                        self.sequenceDataDict[sequenceName] = sequence
//                    }
//                }
//            }
//        })
//    }
    
    internal func retrieveSequenceData(sequenceName: String) {
        if sequenceRefs[sequenceName] == nil {
            let sequenceDataRef = Database.database().reference().child("sequenceData/\(sequenceName)")
            sequenceDataRef.observe(.value, with: { [unowned self] snapshot in
                if let sequenceDataDict = snapshot.value as? NSDictionary {
                    let sequence = AnimationSequenceDataContainer(sequenceName: sequenceName, snapshotDict: sequenceDataDict)
                    self.retrieveAnimationDataFromSequenceData(sequenceDataContainer: sequence)
                    self.sequenceDataDict[sequenceName] = sequence
                }
            })
            sequenceRefs[sequenceName] = sequenceDataRef
        }
    }
    
    internal func retrieveAnimationDataFromSequenceData(sequenceDataContainer: AnimationSequenceDataContainer) {
        for sequenceData in sequenceDataContainer.sequenceArray {
            retrieveAnimationData(animationName: sequenceData.instructorAnimation, retrieveInstruction: true)
            retrieveAnimationData(animationName: sequenceData.ukeAnimation)
        }
    }
    
    // need a way to retrieve orphan animations too? or just keep addding to dummy sequence
    internal func retrieveAnimationData(animationName: String?, retrieveInstruction: Bool = false) {
        guard let animationName = animationName else {
            return
        }
        
        if animationRefs[animationName] == nil {
            let animationDataRef = Database.database().reference().child("animationData/\(animationName)")
            animationDataRef.observe(.value, with: { [unowned self] snapshot in
                if let animationDict = snapshot.value as? NSDictionary {
                    let animationData = CharacterAnimationData(animationName: animationName, snapshotDict: animationDict)
                    //DH: dae files can't be opened from the documents directory it seems... :(
                    self.downloadFileIfNecessary(path: animationData.fileName)
                    if retrieveInstruction {
                        self.retrieveInstructionData(animationName: animationName)
                    }
                    self.animationDataDict[animationName] = animationData
                }
            })
            animationRefs[animationName] = animationDataRef
        }
    }
    
    internal func retrieveInstructionData(animationName: String) {
        if instructionRefs[animationName] == nil {
            let instructionDataRef = Database.database().reference().child("instructionData/\(animationName)")
            instructionDataRef.observe(.value, with: { [unowned self] snapshot in
                if let instructionDict = snapshot.value as? NSDictionary {
                    var instructionArray: [AnimationInstructionData] = []
                    instructionDict.forEach({ obj in
                        if let timestamp = obj.key as? String, let dict = obj.value as? NSDictionary {
                            let text = dict["text"] as? String ?? ""
                            let soundID = dict["soundID"] as? Int
                            instructionArray.append(AnimationInstructionData(timestamp: Double(timestamp) ?? 0, text: text, animationName: animationName, soundID: soundID))
                        }
                    })
                    self.instructionDataDict[animationName] = instructionArray
                }
            })
            instructionRefs[animationName] = instructionDataRef
        }
    }
    
    // MARK: - Files
    
    func downloadFileIfNecessary(path: String, completion: (() -> Void)? = nil) {
        if !fileExist(path: path) {
            print("downloading file...")
            downloadFile(path: path, completion: completion)
        } else {
            print("file already exists")
            completion?()
        }
    }
    
    func uploadFeedData(data: Data?, completion: @escaping ((String?)->Void)) {
        if let data = data {
            let compressedData = try! data.gzipped(level: .bestCompression)
            
            // Create a root reference
            let storageRef = Storage.storage().reference()
            
            // Create a reference to the file you want to upload
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            let date = Date()
            let dateString = dateFormatter.string(from: date)
            
            
            let path = "images/\(Constants.AppKey)/uploads/\(dateString)/\(UUID().uuidString).gif"
            let riversRef = storageRef.child(path)
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putData(compressedData, metadata: nil) { (metadata, error) in
                print(metadata)
                print(error)
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    completion(nil)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                completion(path)
            }
        } else {
            completion(nil)
        }
    }
    
    func uploadFeedImage(image: UIImage, completion: @escaping ((String?)->Void)) {
        if let data = UIImagePNGRepresentation(image) {
            
            // Create a root reference
            let storageRef = Storage.storage().reference()
            
            // Create a reference to the file you want to upload
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy"
            dateFormatter.locale = Locale.init(identifier: "en_GB")
            let date = Date()
            let dateString = dateFormatter.string(from: date)
            
            
            let path = "images/\(Constants.AppKey)/uploads/\(dateString)/\(UUID().uuidString).jpg"
            let riversRef = storageRef.child(path)
            
            // Upload the file to the path "images/rivers.jpg"
            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
                print(metadata)
                print(error)
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata.downloadURL
                completion(path)
            }
        }
    }
    
    func downloadFile(path: String, completion: (() -> Void)? = nil) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child(path)
        print(path)
        let downloadTask = imageRef.write(toFile: URL(fileURLWithPath: "\(getDocumentsDirectory())/\(path)")) { url, error in
            if let error = error {
                print("ERROR: \(error)")
                // Uh-oh, an error occurred!
            } else {
                print("File written successfully")
                // Local file URL for "images/island.jpg" is returned
                completion?()
            }
        }
    }
    
    func fileExist(path: String) -> Bool {
        // bundle
        if let bundlePath = Bundle.main.path(forResource: path, ofType: nil) {
            if FileManager.default.fileExists(atPath: bundlePath) {
                return true
            }
        }
        // documents
        return FileManager.default.fileExists(atPath: "\(getDocumentsDirectory())/\(path)")
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}

// MARK: - Structs

struct BreathFeedItem {
    let key: String?
    let timestamp: TimeInterval
    let breathCount: Int
    let imagePathArray: [String]
    let userId: String
    let userName: String
    let coordinate: CLLocationCoordinate2D?
    let city: String?
    let rating: Int?
    let comment: String?
    let isInappropriate: Int
    
    init(key: String? = nil, timestamp: TimeInterval, imagePathArray: [String], userId: String, userName: String, breathCount: Int, city: String?, coordinate: CLLocationCoordinate2D?, rating: Int?, comment: String?, isInappropriate: Int = 0) {
        self.key = key
        self.timestamp = timestamp
        self.imagePathArray = imagePathArray
        self.userId = userId
        self.userName = userName
        self.breathCount = breathCount
        self.city = city
        self.coordinate = coordinate
        self.rating = rating
        self.comment = comment
        self.isInappropriate = isInappropriate
    }
    
    init(key: String?, snapshotDict: NSDictionary) {
        self.key = key
        timestamp = snapshotDict["timestamp"] as? TimeInterval ?? 0
        imagePathArray = snapshotDict["imagePathArray"] as? [String] ?? []
        userId = snapshotDict["userId"] as? String ?? ""
        userName = snapshotDict["userName"] as? String ?? ""
        breathCount = snapshotDict["breathCount"] as? Int ?? 0
        if let lat = snapshotDict["latitude"] as? CLLocationDegrees,
            let lng = snapshotDict["longitude"] as? CLLocationDegrees {
            coordinate = CLLocationCoordinate2DMake(lat, lng)
        } else {
            coordinate = nil
        }
        if let city = snapshotDict["city"] as? String {
            self.city = city
        } else {
            city = nil
        }
        if let rating = snapshotDict["rating"] as? Int {
            self.rating = rating
        } else {
            rating = nil
        }
        if let comment = snapshotDict["comment"] as? String {
            self.comment = comment
        } else {
            comment = nil
        }
        isInappropriate = snapshotDict["inappropriate"] as? Int ?? 0

    }
	
    func valueDict() -> [String: Any] {
        var dict: [String: Any] = ["timestamp": timestamp,
                "imagePathArray": imagePathArray,
                "userId": userId,
                "userName": userName,
                "breathCount": breathCount]
        if let coordinate = coordinate {
            dict["latitude"] = coordinate.latitude
            dict["longitude"] = coordinate.longitude
        }
        if let city = city {
            dict["city"] = city
        }
        if let rating = rating {
            dict["rating"] = rating
        }
        if let comment = comment {
            dict["comment"] = comment
        }
        dict["inappropriate"] = isInappropriate
        return dict
    }
}

struct AnimationPackage {
    let packageName: String
    let packageDescription: String
    let imageBGPath: String
    let tokenCost: Int
    
    init(snapshotDict: NSDictionary) {
        packageName = snapshotDict["packageName"] as? String ?? ""
        packageDescription = snapshotDict["packageDescription"] as? String ?? ""
        imageBGPath = snapshotDict["imageBGPath"] as? String ?? ""
        tokenCost = snapshotDict["tokenCost"] as? Int ?? 1
    }
}

struct AnimationSequenceDataContainer: SearchableData {
    let sequenceName: String
    let sequenceDescription: String
    let sequenceArray: [AnimationSequenceData]
    let packageName: String
    
    var showHud = true
    
    init(sequenceName: String, snapshotDict: NSDictionary) {
        self.sequenceName = sequenceName
        sequenceDescription = snapshotDict["sequenceDescription"] as? String ?? ""
        packageName = snapshotDict["packageName"] as? String ?? ""
        showHud = snapshotDict["showHud"] as? Bool ?? true
        
        var sequenceArrayTemp: [AnimationSequenceData] = []
        if let sequenceDataArray = snapshotDict["sequenceArray"] as? NSArray {
            for sequenceData in sequenceDataArray {
                if let sequenceDict = sequenceData as? NSDictionary {
                    let sequence = AnimationSequenceData(snapshotDict: sequenceDict)
                    sequenceArrayTemp.append(sequence)
                }
            }
        }
        sequenceArray = sequenceArrayTemp
    }
    
    func searchableString() -> String {
        return "\(sequenceName): \(sequenceDescription)"
    }
    
    func sortPriority() -> Int {
        return 0
    }
}

struct AnimationSequenceData {
    let instructorAnimation: String
    let ukeAnimation: String?
    var delay: TimeInterval = 0
    var speed: Double = 1
    var ukeSpeed: Double = 1
    var repeatCount: Float = 0
    
    init(instructorAnimation: String, ukeAnimation: String? = nil, delay: TimeInterval = 0, speed: Double = 1, repeatCount: Float = 0) {
        self.instructorAnimation = instructorAnimation
        self.ukeAnimation = ukeAnimation
        self.delay = delay
        self.speed = speed
        self.repeatCount = repeatCount
    }
    
    init(snapshotDict: NSDictionary) {
        instructorAnimation = snapshotDict["instructorAnimation"] as? String ?? ""
        ukeAnimation = snapshotDict["ukeAnimation"] as? String ?? ""
        delay = snapshotDict["delay"] as? TimeInterval ?? 0
        speed = snapshotDict["speed"] as? Double ?? 1
        ukeSpeed = snapshotDict["ukeSpeed"] as? Double ?? 1
        repeatCount = snapshotDict["repeat"] as? Float ?? 0
    }
}

struct CharacterAnimationData: SearchableData {
    let fileName: String
    let instructorAnimation: String
    let ukeAnimation: String?
    let relatedAnimations: [String]?
    let animationDescription: String
    let breathProgram: BreathProgram?
    
    init(animationName: String, snapshotDict: NSDictionary) {
        instructorAnimation = animationName
        fileName = snapshotDict["fileName"] as? String ?? ""
        ukeAnimation = snapshotDict["ukeAnimation"] as? String ?? ""
        if let relatedAnimationsDict = snapshotDict["relatedAnimations"] as? NSDictionary {
            relatedAnimations = relatedAnimationsDict.allKeys as? [String]
        } else {
            relatedAnimations = nil
        }
        animationDescription = snapshotDict["animationDescription"] as? String ?? ""
        
        if let breathProgramDict = snapshotDict["breathProgram"] as? NSDictionary {
            breathProgram = BreathProgram(snapshotDict: breathProgramDict)
        } else {
            breathProgram = nil
        }
    }
    
    init(fileName: String, instructorAnimation: String, ukeAnimation: String? = nil, relatedAnimations: [String]? = nil, animationDescription: String = "") {
        self.fileName = fileName
        self.ukeAnimation = ukeAnimation
        self.relatedAnimations = relatedAnimations
        self.instructorAnimation = instructorAnimation
        self.animationDescription = animationDescription
        self.breathProgram = nil
    }
    
    func searchableString() -> String {
        return animationDescription
    }
    
    func sortPriority() -> Int {
        return 1
    }
}

struct BreathProgram {
    let sessionTime: Double
    let soundArray: [BreathProgramSound]
    let parameterArray: [BreathProgramParameter]
    let repeatSoundID: Int?
    
    init(snapshotDict: NSDictionary) {
        var p: [BreathProgramParameter] = []
        if let pArray = snapshotDict["parameterArray"] as? NSArray {
            for parameter in pArray {
                if let parameter = parameter as? NSDictionary {
                    p.append(BreathProgramParameter(snapshotDict: parameter))
                }
            }
        }
        parameterArray = p
        
        var s: [BreathProgramSound] = []
        if let sArray = snapshotDict["soundArray"] as? NSArray {
            for sound in sArray {
                if let sound = sound as? NSDictionary {
                    s.append(BreathProgramSound(snapshotDict: sound))
                }
            }
        }
        soundArray = s
        
        sessionTime = snapshotDict["sessionTime"] as? Double ?? 0
        repeatSoundID = snapshotDict["repeatSoundID"] as? Int
    }
}

struct BreathProgramSound {
    let soundID: Int
    let timestamp: Double
    
    init(snapshotDict: NSDictionary) {
        timestamp = snapshotDict["timestamp"] as? Double ?? 0
        soundID = snapshotDict["soundID"] as? Int ?? 0
    }
}

class BreathProgramParameter {
    let startTime: Double
    let breathTimeUp: Double
    let breathTimeDown: Double
    let soundID: Int
    
    init(snapshotDict: NSDictionary) {
        startTime = snapshotDict["startTime"] as? Double ?? 0
        breathTimeUp = snapshotDict["breathTimeUp"] as? Double ?? 0
        breathTimeDown = snapshotDict["breathTimeDown"] as? Double ?? 0
        soundID = snapshotDict["soundID"] as? Int ?? 0
    }
}

func ==<T: BreathProgramParameter>(lhs: T, rhs: T) -> Bool {
    return lhs.startTime == rhs.startTime &&
        rhs.breathTimeUp == lhs.breathTimeUp &&
        rhs.breathTimeDown == lhs.breathTimeDown
}


struct AnimationInstructionData: SearchableData {
    let timestamp: TimeInterval
    let text: String
    let animationName: String
    let soundID: Int?
    
    func searchableString() -> String {
        return text
    }
    
    func sortPriority() -> Int {
        return 2
    }
}

