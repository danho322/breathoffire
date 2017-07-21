//
//  ARXCharacterSceneView.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/20/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import SceneKit

class ARXCharacterSceneView: SCNView {
    var model: VirtualObject?
    
    override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        setupScene()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupScene()
    }
    
    func startAnimation(sequence: AnimationSequenceDataContainer?) {
        if let sequence = sequence {
            model?.loadAnimationSequence(animationSequence: sequence.sequenceArray)
        }
    }
    
    internal func setupScene() {
        self.scene = SCNScene()
        let male = Instructor()
        male.loadModel()
        self.model = male
        let target = male.armatureNode()
        
        // create a new scene using the Collada file imported fom Blender
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 2)
        let constraint = SCNLookAtConstraint(target: target?.childNode(withName: "Pelvis", recursively: true))
        cameraNode.constraints = [constraint]
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        self.scene?.rootNode.addChildNode(male)
        self.scene?.rootNode.addChildNode(cameraNode)
        self.scene?.rootNode.addChildNode(lightNode)
        self.scene?.rootNode.addChildNode(ambientLightNode)
    
    
        // allows the user to manipulate the camera
        self.pointOfView = cameraNode
    
        // configure the view
        self.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
    
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
            self.alpha = 1
        })
        alphaAnimator.startAnimation()
    }
}
