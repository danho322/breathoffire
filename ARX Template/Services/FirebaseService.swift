//
//  FirebaseService.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/7/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage
import UIKit

struct Constants {
    static let AppKey = "jiujitsu"
}
class FirebaseService {
    static let sharedInstance = FirebaseService()
    
    var sectionRefs: [String: DatabaseReference] = Dictionary()
    var sequenceRefs: [String: DatabaseReference] = Dictionary()
    var animationRefs: [String: DatabaseReference] = Dictionary()
    var instructionRefs: [String: DatabaseReference] = Dictionary()
    
    var sequenceSections: [String] = []
    var sequenceRows: [String: [String]] = Dictionary()
    var sequenceDataDict: [String: AnimationSequenceDataContainer] = Dictionary()
    var animationDataDict: [String: CharacterAnimationData] = Dictionary()
    var instructionDataDict: [String: [AnimationInstructionData]] = Dictionary()
    
    // MARK: - Realtime DB
    
    func setUserAttribute(userId: String, userName: String) {
        let userRef = Database.database().reference().child("users/\(Constants.AppKey)")
        
        userRef.child("\(userId)/userName").setValue(userName)
        userRef.child("\(userId)/lastLoggedIn").setValue(Date().description)
        
        incrementAttributeCount(userId: userId, attributeName: "playCount")
    }
    
    func incrementAttributeCount(userId: String, attributeName: String) {
        let ref = Database.database().reference().child("users/\(Constants.AppKey)/\(userId)")
        ref.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            if var post = currentData.value as? [String : AnyObject] {
                var starCount = post[attributeName] as? Int ?? 0
                starCount += 1
                post[attributeName] = starCount as AnyObject?
                
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
    
    // MARK: - Image loading
    
    func retrieveBackgroundImage(completion: @escaping (UIImage) -> Void) {
        let sectionNamesRef = Database.database().reference().child("config/\(Constants.AppKey)/menuBackgroundImage")
        sectionNamesRef.observe(.value, with: { [unowned self] snapshot in
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
                        if let timestamp = obj.key as? String, let text = obj.value as? String {
                            instructionArray.append(AnimationInstructionData(timestamp: Double(timestamp) ?? 0, text: text, animationName: animationName))
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
            downloadFile(path: path, completion: completion)
        } else {
            completion?()
        }
    }
    
    func downloadFile(path: String, completion: (() -> Void)? = nil) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child(path)
        print(path)
        let downloadTask = imageRef.write(toFile: URL(fileURLWithPath: "\(getDocumentsDirectory())/\(path)")) { url, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
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

struct AnimationSequenceDataContainer: SearchableData {
    let sequenceName: String
    let sequenceDescription: String
    let sequenceArray: [AnimationSequenceData]
    
    init(sequenceName: String, snapshotDict: NSDictionary) {
        self.sequenceName = sequenceName
        sequenceDescription = snapshotDict["sequenceDescription"] as? String ?? ""
        
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
        repeatCount = snapshotDict["repeat"] as? Float ?? 0
    }
}

struct CharacterAnimationData: SearchableData {
    let fileName: String
    let instructorAnimation: String
    let ukeAnimation: String?
    let relatedAnimations: [String]?
    let animationDescription: String
    
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
    }
    
    init(fileName: String, instructorAnimation: String, ukeAnimation: String? = nil, relatedAnimations: [String]? = nil, animationDescription: String = "") {
        self.fileName = fileName
        self.ukeAnimation = ukeAnimation
        self.relatedAnimations = relatedAnimations
        self.instructorAnimation = instructorAnimation
        self.animationDescription = animationDescription
    }
    
    func searchableString() -> String {
        return animationDescription
    }
    
    func sortPriority() -> Int {
        return 1
    }
}

struct AnimationInstructionData: SearchableData {
    let timestamp: TimeInterval
    let text: String
    let animationName: String
    
    func searchableString() -> String {
        return text
    }
    
    func sortPriority() -> Int {
        return 2
    }
}

