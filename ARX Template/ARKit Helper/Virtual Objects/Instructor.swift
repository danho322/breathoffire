//
//  Male.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/28/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

enum InstructorType: Int {
    case generic = 0
    case dennySimple = 1
    case dennyComplex = 2
    case armTriangle = 3
    
    func fileName() -> String {
        switch self {
        case .generic:
            return "JiujitsuModel4"
        case .dennySimple:
            return "final_complete_character2"
        case .dennyComplex:
            return "character_proper_rig_complex"
        case .armTriangle:
            return "arm_triangle_rig"
        }
    }
    
    func armtatureName() -> String {
        switch self {
        case .armTriangle:
            return "Armtr"
        default:
            return "Armtr"
        }
    }
}

class Instructor: VirtualObject {
    
    var type: InstructorType
    var scene: SCNScene?
    
    init(type: InstructorType? = nil) {
        let typeToUse = type ?? .generic
        self.type = typeToUse
        super.init()
        self.name = "Virtual object root node"
        self.modelName =  typeToUse.fileName()
        self.fileExtension = "dae"
        self.thumbImage = UIImage(named: "cup")
        self.title = "Jiujitsu"
        self.armatureName = typeToUse.armtatureName()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadModel() {
        // also maybe try as a scenesource
        
        guard let virtualObjectScene = SCNScene(named: "\(modelName).\(fileExtension)", inDirectory: "Models.scnassets/jiujitsu") else {
            return
        }
        for node in virtualObjectScene.rootNode.childNodes {
            addChildNode(node)
        }

        
        updateRenderOrder()
        addPhysicsBody(nodeName: "Danny_Prokopo_002")
        
        modelLoaded = true
    }
    
    override func armatureNode() -> SCNNode? {
        
        return childNode(withName: armatureName, recursively: true)
    }
    
    func loadIdleAnimation() {
        if let idleAnimation = DataLoader.sharedInstance.characterAnimation(name: "Movement Test 1") {
            loadAnimationData(animationData: idleAnimation, speed: 1, repeatCount: Float.greatestFiniteMagnitude)
        }
    }
}
