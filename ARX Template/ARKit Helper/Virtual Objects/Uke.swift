//
//  Uke.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/2/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SceneKit

class Uke: VirtualObject {
    var type: InstructorType
    
    override init() {
        type = .generic
        super.init()

        self.name = "Virtual object root node"
        self.modelName = "JiujitsuModel4"
        self.fileExtension = "dae"
        self.thumbImage = UIImage(named: "cup")
        self.title = "NakedMale"
        self.armatureName = "Armtr"
    }
    
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
    
    override func loadAnimationSequence(animationSequence: [AnimationSequenceData], isDemoMode: Bool = false) {
        
        super.loadAnimationSequence(animationSequence: animationSequence)
    }
    
    override func loadCurrentAnimationIndex() {
        var shouldHide = true
        if currentAnimationIndex < animationSequence.count {
            let currentAnimation = animationSequence[currentAnimationIndex]
            if let animationName = currentAnimation.ukeAnimation, let animationData = DataLoader.sharedInstance.characterAnimation(name: animationName), animationName.characters.count > 0 {
                loadAnimationData(animationData: animationData, speed: currentAnimation.ukeSpeed, repeatCount: currentAnimation.repeatCount)
                shouldHide = false
            }
            
        }
        isHidden = shouldHide
    }
    
    override func armatureNode() -> SCNNode? {
        return childNode(withName: armatureName, recursively: true)
    }
}
