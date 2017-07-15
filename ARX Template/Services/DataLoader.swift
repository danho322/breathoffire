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
//    let characterAnimationDatas = [
//        CharacterAnimationData(fileName: "Models.scnassets/nakedman/TaiChi_1_468.dae",
//                               instructorAnimation: "Tai Chi 1",
//                               ukeAnimation: "Salsa",
//                               instructionData: [
//                                AnimationInstructionData(timestamp: 0.1, text: "Tai Chi"),
//                                AnimationInstructionData(timestamp: 3, text: "Shake your hands like an old man"),
//                                AnimationInstructionData(timestamp: 6, text: "Slowly raise up your arms"),
//                                AnimationInstructionData(timestamp: 10, text: "Hold the pose"),
//                                AnimationInstructionData(timestamp: 15, text: "Do some karate stuff"),
//                                AnimationInstructionData(timestamp: 18, text: "Look badass while you're doing it"),
//                                AnimationInstructionData(timestamp: 24, text: "Flex the core, keep it flexxed, flex it up"),
//                                AnimationInstructionData(timestamp: 28, text: "Hold the flex"),
//                                AnimationInstructionData(timestamp: 35, text: "Now for the grand finale, look like you might slap a bitch"),
//                                AnimationInstructionData(timestamp: 37, text: "But don't slap anyone")],
//                               relatedAnimations: ["Tai Chi 2"]),
//        CharacterAnimationData(fileName: "Models.scnassets/nakedman/Salsa.dae",
//                               instructorAnimation: "Salsa",
//                               ukeAnimation: nil,
//                               instructionData: nil,
//                               relatedAnimations: nil),
//        CharacterAnimationData(fileName: "Models.scnassets/nakedman/TaiChi_468_738_transition.dae",
//                               instructorAnimation: "Tai Chi 2",
//                               ukeAnimation: nil,
//                               instructionData: nil,
//                               relatedAnimations: ["Tai Chi 3"]),
//        CharacterAnimationData(fileName: "Models.scnassets/nakedman/TaiChi_738_1581.dae",
//                               instructorAnimation: "Tai Chi 3",
//                               ukeAnimation: nil,
//                               instructionData: nil,
//                               relatedAnimations: ["Tai Chi 4"]),
//        CharacterAnimationData(fileName: "Models.scnassets/nakedman/TaiChi_1581_3104_transition.dae",
//                               instructorAnimation: "Tai Chi 4",
//                               ukeAnimation: nil,
//                               instructionData: nil,
//                               relatedAnimations: ["Tai Chi 5"]),
//        CharacterAnimationData(fileName: "Models.scnassets/nakedman/TaiChi_3104_3559.dae",
//                               instructorAnimation: "Tai Chi 5",
//                               ukeAnimation: nil,
//                               instructionData: nil,
//                               relatedAnimations: ["Tai Chi 1"])
//                                  ]
    
    // Labels
    
    func textForPlacementState(_ state: ARObjectPlacementState) -> String {
        var text = ""
        switch state {
        case .ScanningEmpty:
            text = "Scan your surroundings for your virtual space"
        case .ScanningProgress:
            text = "Surface detected! Continue scanning to increase floor space"
        case .ScanningReady:
            text = "Virtual space ready. Ready to load?"
        case .PlacedScaling:
            text = "Use two fingers to scale and rotate"
        case .PlacedRotating:
            text = "Use two fingers to rotate your model"
        case .PlacedMoving:
            text = "Use one finger to move"
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
}

struct SceneModelData {
    let fileName: String
    let armatureName: String
}

enum ARObjectPlacementState {
    case
    ScanningEmpty,
    ScanningProgress,
    ScanningReady,
    PlacedScaling,
    PlacedMoving,
    PlacedRotating,
    PlacedReady
    
    func hideAddButton() -> Bool {
        return (self != .ScanningReady && !isPlaced()) || self == .PlacedReady
    }
    
    func hideStatusLabel() -> Bool {
        return self == .PlacedReady
    }
    
    func showDebugVisuals() -> Bool {
        return self == .ScanningEmpty || self == .ScanningProgress || self == .ScanningReady
    }
    
    func isPlacingAllowed() -> Bool {
        return self != .ScanningEmpty && self != .ScanningProgress
    }
    
    func isPlaced() -> Bool {
        return self == .PlacedReady || self == .PlacedRotating || self == .PlacedScaling || self == .PlacedMoving
    }
    
    func isSingleGestureAllowed() -> Bool {
        return self == .PlacedMoving
    }
    
    func isDoubleGestureAllowed() -> Bool {
        return isRotationAllowed() || isScalingAllowed()
    }
    
    func isRotationAllowed() -> Bool {
        return self == .PlacedRotating || self == .PlacedScaling
    }
    
    func isScalingAllowed() -> Bool {
        return self == .PlacedScaling || self == .PlacedRotating
    }
    
    func isUpdatePlanesAllowed() -> Bool {
        return !isPlaced()
    }
    
    func isMovingAllowed() -> Bool {
        return self == .PlacedMoving
    }
}
