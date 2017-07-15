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

class Instructor: VirtualObject {
    
    var scene: SCNScene?
    
    override init() {
        super.init()
        self.name = "Virtual object root node"
        self.modelName = "Messi"
        self.fileExtension = "dae"
        self.thumbImage = UIImage(named: "cup")
        self.title = "Jiujitsu"
        self.armatureName = "Armtr"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadModel() {
        // also maybe try as a scenesource
        
        guard let virtualObjectScene = SCNScene(named: "\(modelName).\(fileExtension)", inDirectory: "art.scnassets") else {
            return
        }
        
        virtualObjectScene.rootNode.enumerateChildNodes({ node, stop in
            node.movabilityHint = .movable
            print(node.name)
        })
//        for child in virtualObjectScene.rootNode.childNodes {
//            print("child set to movable: \(child).. should we set subchildren too?")
////            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
//            child.movabilityHint = .movable
//        }
    
        for node in virtualObjectScene.rootNode.childNodes {
            addChildNode(node)
        }
//        scene = virtualObjectScene
        
        modelLoaded = true
    }
    
    func armatureNode() -> SCNNode? {
        return childNode(withName: armatureName, recursively: true)
    }
    
    override func loadAnimation(_ animation: CAAnimation, key: String) {
//        enumerateChildNodes({ node, stop in
//            print("self childnode: \(node)")
//        })
//
//        scene?.rootNode.enumerateChildNodes({ node, stop in
//            print("scene childnode: \(node)")
//        })
        
//        childNode(withName: "Root", recursively: true)?.addAnimation(animation, forKey: key)
        let armtr = armatureNode()
        armtr?.addAnimation(animation, forKey: key)
    }
}
