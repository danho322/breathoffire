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
    override init() {
        super.init()
        self.name = "Virtual object root node"
        self.modelName = "NakedMaleWithTextures"
        self.fileExtension = "dae"
        self.thumbImage = UIImage(named: "cup")
        self.title = "NakedMale"
        self.armatureName = "Armtr"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "\(modelName).\(fileExtension)", inDirectory: "Models.scnassets/nakedman") else {
            return
        }
        
        for child in virtualObjectScene.rootNode.childNodes {
            child.movabilityHint = .movable
        }
        
        self.opacity = 0
        self.addChildNode(virtualObjectScene.rootNode)
        
        modelLoaded = true
    }
    
    override func loadAnimationSequence(animationSequence: [AnimationSequenceData]) {
        
        super.loadAnimationSequence(animationSequence: animationSequence)
    }
    
    override func loadCurrentAnimationIndex() {
        var shouldHide = true
        if currentAnimationIndex < animationSequence.count {
            let currentAnimation = animationSequence[currentAnimationIndex]
            if let animationName = currentAnimation.ukeAnimation, let animationData = DataLoader.sharedInstance.characterAnimation(name: animationName), animationName.characters.count > 0 {
                loadAnimationData(animationData: animationData, speed: currentAnimation.speed, repeatCount: currentAnimation.repeatCount)
                shouldHide = false
            }
            
        }
        isHidden = shouldHide
    }
    
    override func armatureNode() -> SCNNode? {
        return childNode(withName: armatureName, recursively: true)
    }
}
