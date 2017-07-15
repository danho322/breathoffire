/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Extensions on SceneKit classes.
*/

import SceneKit
import SpriteKit

// MARK: SceneKit

extension SCNTransaction {
    class func animateWithDuration(_ duration: CFTimeInterval = 0.25, timingFunction: CAMediaTimingFunction? = nil, completionBlock: (() -> Void)? = nil, animations: () -> Void) {
        begin()
        self.animationDuration = duration
        self.completionBlock = completionBlock
        self.animationTimingFunction = timingFunction
        animations()
        commit()
    }
}

extension SCNPhysicsContact {
    func match(_ category: Int, block: (_ matching: SCNNode, _ other: SCNNode) -> Void) {
        if self.nodeA.physicsBody!.categoryBitMask == category {
            block(self.nodeA, self.nodeB)
        }
  
        if self.nodeB.physicsBody!.categoryBitMask == category {
            block(self.nodeB, self.nodeA)
        }
    }
}

extension SCNAudioSource {
    convenience init(name: String, volume: Float = 1.0, positional: Bool = true, loops: Bool = false, shouldStream: Bool = false, shouldLoad: Bool = true) {
        self.init(named: "game.scnassets/sounds/\(name)")!
        self.volume = volume
        self.isPositional = positional
        self.loops = loops
        self.shouldStream = shouldStream
        if shouldLoad {
            load()
        }
    }
}

// MARK: SpriteKit

extension SKSpriteNode {
    convenience init(imageNamed name: String, position: CGPoint, scale: CGFloat = 1.0) {
        self.init(imageNamed: name)
        self.position = position
        xScale = scale
        yScale = scale
    }
}

// MARK: Simd

extension float2 {
    init(_ v: CGPoint) {
        self.init(Float(v.x), Float(v.y))
    }
}

// MARK: CoreAnimation

extension CAAnimation {
    class func animationWithSceneNamed(_ name: String) -> CAAnimation? {
        var animation: CAAnimation?
        var scene: SCNScene?
        
        // hack to see if animations load this way
//        let collada = Bundle.mainBundle().URLForResource("art.scnassets/\(daeNamed)", withExtension: "dae")!
//        return SCNSceneSource(URL: collada, options: nil)!
//        let resourceName = "Models.scnassets/nakedman/WalkingAnimation"
//        let nameExtension = "dae"
//        if let collada = Bundle.main.url(forResource: resourceName, withExtension: nameExtension) {
//            if let sceneSource = SCNSceneSource(url: collada, options: nil) {
//                print(sceneSource.identifiersOfEntries(withClass: CAAnimation.self))
//                return sceneSource.entryWithIdentifier("WalkingAnimation-1", withClass: CAAnimation.self)!
//
//            }
//        }
        
        scene = SCNScene(named: "art.scnassets/MessiIdle.dae")
        // this is the way we were doing it before
        if scene == nil {   // Try documents directory
            let docURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let fileURL = docURL.appendingPathComponent(name)
            if let sceneSource = SCNSceneSource(url: fileURL, options: nil) {
                scene = try? sceneSource.scene(options: nil)
            }
        }
        if let scene = scene {
            
            scene.rootNode.enumerateChildNodes({ (child, stop) in
                if child.animationKeys.count > 0 {
                    animation = child.animation(forKey: child.animationKeys.first!)
                    stop.initialize(to: true)
                }
            })
        }
        return animation
    }
}
