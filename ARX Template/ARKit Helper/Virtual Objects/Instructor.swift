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
        self.modelName = "JiujitsuModel4"
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
        
        guard let virtualObjectScene = SCNScene(named: "\(modelName).\(fileExtension)", inDirectory: "Models.scnassets/jiujitsu") else {
            return
        }
        for node in virtualObjectScene.rootNode.childNodes {
            addChildNode(node)
        }

        
        updateRenderOrder()
        
        modelLoaded = true
    }
    
    override func armatureNode() -> SCNNode? {
        return childNode(withName: armatureName, recursively: true)
    }
}
