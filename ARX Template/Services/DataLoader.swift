//
//  DataLoader.swift
//  SceneKitDemo
//
//  Created by Daniel Ho on 6/18/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import QuartzCore
import SceneKit
import Hero
import FirebaseDatabase

struct DataLoader {
    static let sharedInstance = DataLoader()
    
    let armatureName = "Armtr"
    let sceneFile = "Models.scnassets/nakedman/NakedMaleWithTextures.dae"

    
    // Labels
    
    func textForPlacementState(_ state: ARObjectPlacementState) -> String {
        var text = ""
        switch state {
        case .ScanningEmpty:
            text = "Scan the floor slowly to map out your virtual gym"
        case .ScanningProgress:
            text = "Surface detected! Continue scanning to increase floor space"
        case .PlacedEditing:
            text = "Use two fingers to scale/rotate, tap when ready"
        default:
            break
        }
        
        return text
    }
    
    // Models
    
    func instructionData(animationName: String) -> [AnimationInstructionData]? {
        return FirebaseService.sharedInstance.instructionDataDict[animationName]
    }
    
    func characterAnimation(name: String) -> CharacterAnimationData? {
        return FirebaseService.sharedInstance.animationDataDict[name]
    }
    
    func armatureNode(in scene: SCNScene?) -> SCNNode? {
        if let scene = scene {
            return scene.rootNode.childNode(withName: armatureName, recursively: true)
        }
        return nil
    }
    
    // Section Data
    
    func sequenceSections() -> [String] {
        return FirebaseService.sharedInstance.sequenceSections
    }
    
    func sequenceRows(sectionName: String) -> [String]? {
        return FirebaseService.sharedInstance.sequenceRows[sectionName]
    }
    
    func sequenceData(sequenceName: String) -> AnimationSequenceDataContainer? {
        return FirebaseService.sharedInstance.sequenceDataDict[sequenceName]
    }
    
    // All Data
    
    func allSearchableData() -> [SearchableData] {
//        var sequenceDataDict: [String: AnimationSequenceDataContainer] = Dictionary()
//        var animationDataDict: [String: CharacterAnimationData] = Dictionary()
//        var instructionDataDict: [String: [AnimationInstructionData]] = Dictionary()
        var data: [SearchableData] = []
        let sequences = FirebaseService.sharedInstance.sequenceDataDict.map({ $0.1 })
        let animations = characterAnimations()
        let instructions = animationInstructions().filter({ instruction in
            animations.contains(where: { $0.instructorAnimation == instruction.animationName })
        })
        data = data + sequences
        data = data + animations
        data = data + instructions
        return data
    }
    
    func animationInstructions() -> [AnimationInstructionData] {
        var instructions: [AnimationInstructionData] = []
        for instructionArray in FirebaseService.sharedInstance.instructionDataDict.values {
            for data in instructionArray {
                instructions.append(data)
            }
        }
        return instructions
    }
    
    func characterAnimations() -> [CharacterAnimationData] {
        return FirebaseService.sharedInstance.animationDataDict.values.filter { animation in
            return FirebaseService.sharedInstance.fileExist(path: animation.fileName)
        }
    }
    
    // Content
    
    func moveOfTheDay() -> AnimationSequenceDataContainer? {
        return sequenceData(sequenceName: "Yoga Flow A")
        if FirebaseService.sharedInstance.sequenceDataDict.count > 0 {
            let index = Int(arc4random_uniform(UInt32(FirebaseService.sharedInstance.sequenceDataDict.count)))
            let randomMove = Array(FirebaseService.sharedInstance.sequenceDataDict.values)[index]
            return randomMove
        }
        
        return nil
        
//        return sequenceData(sequenceName: "Alan Test Armbar")
    }
    
    func packages() -> [AnimationPackage] {
        return FirebaseService.sharedInstance.animationPackages
    }
    
    func package(packageName: String) -> AnimationPackage? {
        return FirebaseService.sharedInstance.animationPackages.filter({ $0.packageName == packageName }).first
    }
    
    func sequencesInPackage(packageName: String) -> [AnimationSequenceDataContainer] {
        return FirebaseService.sharedInstance.sequenceDataDict.values.filter({ $0.packageName == packageName })
    }
}

struct SceneModelData {
    let fileName: String
    let armatureName: String
}

enum ARObjectPlacementState {
    case
    ScanningEmpty,
    ScanningProgress,
    PlacedEditing,
    PlacedReady
    
    func hideAddButton() -> Bool {
        return !isPlaced() || self == .PlacedReady
    }
    
    func hideStatusLabel() -> Bool {
        return self == .PlacedReady
    }
    
    func showDebugVisuals() -> Bool {
        return self == .ScanningEmpty || self == .ScanningProgress
    }
    
    func isPlacingAllowed() -> Bool {
        return self != .ScanningEmpty && self != .ScanningProgress
    }
    
    func isPlaced() -> Bool {
        return self == .PlacedReady || self == .PlacedEditing
    }
    
    func isDoubleGestureAllowed() -> Bool {
        return isRotationAllowed() || isScalingAllowed()
    }
    
    func isRotationAllowed() -> Bool {
        return self == .PlacedEditing
    }
    
    func isScalingAllowed() -> Bool {
        return self == .PlacedEditing
    }
    
    func isUpdatePlanesAllowed() -> Bool {
        return !isPlaced()
    }
    
    func isMovingAllowed() -> Bool {
        return self != .PlacedReady
    }
}
