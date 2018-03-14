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
            text = "Scan the surface slowly to map out the floor"
        case .ScanningProgress:
            text = "Surface detected! Continue scanning to increase floor space"
        case .PlacedEditing:
            text = "Use two fingers to scale/rotate the Teacher, tap ✓ when ready"
        default:
            break
        }
        
        return text
    }
    
    func viewForPlacementState(_ state: ARObjectPlacementState) -> UIView? {
        var view: UIView?
        switch state {
        case .ScanningEmpty:
            view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            view?.backgroundColor = UIColor.clear
            // handHoldingPhone
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "handHoldingPhone")
            view?.addSubview(imageView)
            imageView.center = CGPoint(x: 25, y: 25)
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.beginTime = CACurrentMediaTime()
            groupAnimation.duration = 1
            groupAnimation.repeatCount = Float.greatestFiniteMagnitude
            groupAnimation.autoreverses = true
            
            let moveX = CABasicAnimation(keyPath: "transform.translation.y")
            moveX.fromValue = 0
            moveX.toValue = 50.0
            
            groupAnimation.animations = [moveX]
            imageView.layer.add(groupAnimation, forKey: nil)
        case .ScanningProgress:
            view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            view?.backgroundColor = UIColor.clear
            // handHoldingPhone
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "handHoldingPhone")
            view?.addSubview(imageView)
            imageView.center = CGPoint(x: 25, y: 25)
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.beginTime = CACurrentMediaTime()
            groupAnimation.duration = 1
            groupAnimation.repeatCount = Float.greatestFiniteMagnitude
            groupAnimation.autoreverses = true
            
            let moveX = CABasicAnimation(keyPath: "transform.translation.x")
            moveX.fromValue = 0
            moveX.toValue = 50.0
            
            groupAnimation.animations = [moveX]
            imageView.layer.add(groupAnimation, forKey: nil)
        case .PlacedEditing:
            view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            view?.backgroundColor = UIColor.clear
            // pinch
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(named: "pinch")
            view?.addSubview(imageView)
            imageView.center = CGPoint(x: 25, y: 25)
            
            let groupAnimation = CAAnimationGroup()
            groupAnimation.beginTime = CACurrentMediaTime()
            groupAnimation.duration = 3
            groupAnimation.repeatCount = Float.greatestFiniteMagnitude
            
            let scaleDown = CABasicAnimation(keyPath: "transform.scale")
            scaleDown.fromValue = 1.2
            scaleDown.toValue = 0.8
            let rotate = CABasicAnimation(keyPath: "transform.rotation")
            rotate.fromValue = .pi/2.0
            rotate.toValue = 0.0
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0.0
            fade.toValue = 1.0
            
            groupAnimation.animations = [scaleDown,rotate,fade]
            imageView.layer.add(groupAnimation, forKey: nil)
        default:
            break
        }
        
        return view
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
    
    func hasARAnimation(sequenceName: String) -> Bool {
        if let animationData = sequenceData(sequenceName: sequenceName) {
            for sequenceData in animationData.sequenceArray {
                if let animationData = characterAnimation(name: sequenceData.instructorAnimation) {
                    if !animationData.fileName.hasSuffix(".dae") {
                        return false
                    }
                } else {
                    return false
                }
            }
        }
        return true
    }
    
    // Content
    
    func moveOfTheDay() -> AnimationSequenceDataContainer? {
        return sequenceData(sequenceName: "Breath of Fire Challenge")
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

enum DurationSequenceType {
    case sequence0, sequence1, sequence2, sequence3, sequence4, sequence5, sequence6
    
    func labelText() -> String {
        switch self {
        case .sequence0:
            return "2 min"
        case .sequence1:
            return "4 min"
        case .sequence2:
            return "7 min"
        case .sequence3:
            return "13 min"
        case .sequence4:
            return "19 min"
        case .sequence5:
            return "25 min"
        case .sequence6:
            return "No time limit"
        }
    }
    
    func sequenceName() -> String {
        switch self {
        case .sequence0:
            return "Breath of Fire 1:1"
        case .sequence1:
            return "Breath of Fire 3:1"
        case .sequence2:
            return "Breath of Fire 5:2"
        case .sequence3:
            return "Breath of Fire 10:3"
        case .sequence4:
            return "Breath of Fire 15:4"
        case .sequence5:
            return "Breath of Fire 20:5"
        case .sequence6:
            return "Breath of Fire Challenge"
        }
    }
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
