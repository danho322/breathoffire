/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Wrapper SceneKit node for virtual objects placed into the AR scene.
 */

import Foundation
import SceneKit
import ARKit

protocol VirtualObjectDelegate {
    func virtualObjectDidFinishAnimation(_ object: VirtualObject)
}

class VirtualObject: SCNNode {
    
    var modelName: String = ""
    var fileExtension: String = ""
    var thumbImage: UIImage!
    var title: String = ""
    var modelLoaded: Bool = false
    var animationSequence: [AnimationSequenceData] = []
    var currentAnimationIndex = 0
    var armatureName = ""
    
    var viewController: ARTechniqueViewController?
    var instructionService: InstructionService?
    var delegate: VirtualObjectDelegate?
    var currentSpeed: Double?
    
    override init() {
        super.init()
        self.name = "Virtual object root node"
    }
    
    init(modelName: String, fileExtension: String, thumbImageFilename: String, title: String) {
        super.init()
        self.name = "Virtual object root node"
        self.modelName = modelName
        self.fileExtension = fileExtension
        self.thumbImage = UIImage(named: thumbImageFilename)
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadModel() {
        guard let virtualObjectScene = SCNScene(named: "\(modelName).\(fileExtension)", inDirectory: "Models.scnassets/\(modelName)") else {
            return
        }
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjectScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            wrapperNode.addChildNode(child)
        }
        self.addChildNode(wrapperNode)
        
        modelLoaded = true
    }
    
    func updateRenderOrder() {
        renderingOrder = 1000
        enumerateChildNodes({ node, stop in
            node.renderingOrder = 1000  // this seemed to do the trick
            node.geometry?.firstMaterial?.readsFromDepthBuffer = true
        })
    }
    
    func unloadModel() {
        for child in self.childNodes {
            child.removeFromParentNode()
        }
        
        modelLoaded = false
    }
    
    func translateBasedOnScreenPos(_ pos: CGPoint, instantly: Bool, infinitePlane: Bool) {
        
        guard let controller = viewController else {
            return
        }
        
        let result = controller.worldPositionFromScreenPosition(pos, objectPos: self.position, infinitePlane: infinitePlane)
        
        controller.moveVirtualObjectToPosition(result.position, instantly, !result.hitAPlane)
    }
    
    // MARK: - Animations
    
    func loadAnimationSequence(animationSequence: [AnimationSequenceData]) {
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: .easeIn, animations: {
            self.opacity = 1
        })
        animator.startAnimation()
        
        currentAnimationIndex = 0
        self.animationSequence = animationSequence
        loadCurrentAnimationIndex()
    }
    
    internal func refreshInstructionService(animationData: CharacterAnimationData, speed: Double) {
        instructionService?.stop()
        if let instructionData = DataLoader.sharedInstance.instructionData(animationName: animationData.instructorAnimation) {
            instructionService?.updateInstructions(instructionDataArray: instructionData)
            instructionService?.start(speed: speed, timeOffset: 0)
        }
    }
    
    internal func loadCurrentAnimationIndex() {
        if currentAnimationIndex < animationSequence.count && currentAnimationIndex >= 0 {
            let currentAnimation = animationSequence[currentAnimationIndex]
            if let animationData = DataLoader.sharedInstance.characterAnimation(name: currentAnimation.instructorAnimation) {
                loadAnimationData(animationData: animationData, speed: currentSpeed ?? currentAnimation.speed, repeatCount: currentAnimation.repeatCount)
            }
        }
    }
    
    func loadAnimationData(animationData: CharacterAnimationData, speed: Double, repeatCount: Float) {
        refreshInstructionService(animationData: animationData, speed: speed)
        let speedToUse = Float(max(0.01, speed))
        removeAllAnimations()
        
        if let animation = CAAnimation.animationWithSceneNamed(animationData.fileName) {
            var animationsToSave: [CAAnimation] = []
            if let group = animation as? CAAnimationGroup, let animations = group.animations {
                for subAnimation in animations {
                    subAnimation.speed = speedToUse
                    subAnimation.fillMode = kCAFillModeBoth
                    subAnimation.isRemovedOnCompletion = false
                    animationsToSave.append(subAnimation)
                }
                group.animations = animationsToSave
                animation.speed = speedToUse
            }
            
            animation.repeatCount = repeatCount
            animation.fadeInDuration = 0
            animation.fadeOutDuration = 0
            animation.delegate = self
            animation.fillMode = kCAFillModeBoth
            animation.isRemovedOnCompletion = false
            loadAnimation(animation, key: animationData.instructorAnimation)
        }
    }
    
    func armatureNode() -> SCNNode? {
        return self
    }
    
    func loadAnimation(_ animation: CAAnimation, key: String) {
        armatureNode()?.addAnimation(animation, forKey: key)
    }
    
    func updateAnimationSpeed(speed: Double) {
        currentSpeed = max(0.01, speed)
        if let armtrNode = armatureNode() {
            print("keys: \(armtrNode.animationKeys)")
            for key in armtrNode.animationKeys {
                // this is beta so is subject to change: https://developer.apple.com/documentation/scenekit/scnanimatable/2866031-addanimationplayer?changes=latest_major
                if let player = animationPlayer(forKey: key) {
                    player.speed = CGFloat(speed)
                }
            }

        }
    }
    
    internal func handleAnimationSequenceFinished() {
        delegate?.virtualObjectDidFinishAnimation(self)
    }
    
    func rewind() {
        currentAnimationIndex -= 1
        if currentAnimationIndex < 0 {
            currentAnimationIndex = animationSequence.count - 1
        }
        loadCurrentAnimationIndex()
    }
    
    func pauseAnimation() {
        updateAnimationSpeed(speed: 0)
    }
    
    func resumeAnimation(speed: Double) {
        updateAnimationSpeed(speed: max(0.01, speed))
    }
    
    func currentAnimationTimeOffset() -> TimeInterval {
        for key in animationKeys {
            if let player = animationPlayer(forKey: key) {
                return player.animation.timeOffset
            }
        }
        return 0
    }
}

extension VirtualObject {
    
    static func isNodePartOfVirtualObject(_ node: SCNNode) -> Bool {
        if node.name == "Virtual object root node" {
            return true
        }
        
        if node.parent != nil {
            return isNodePartOfVirtualObject(node.parent!)
        }
        
        return false
    }
    
    static let availableObjects: [VirtualObject] = [
        Instructor()
    ]
}

// Animations

extension VirtualObject: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        anim.speed = 0
        currentAnimationIndex += 1
        if currentAnimationIndex >= animationSequence.count {
            currentAnimationIndex = 0
            handleAnimationSequenceFinished()
        } else {
            let currentAnimation = animationSequence[currentAnimationIndex]
            DispatchQueue.main.asyncAfter(deadline: .now() + currentAnimation.delay) {
                self.loadCurrentAnimationIndex()
            }
        }
    }
}

// MARK: - Protocols for Virtual Objects

protocol ReactsToScale {
    func reactToScale()
}

extension SCNNode {
    
    func reactsToScale() -> ReactsToScale? {
        if let canReact = self as? ReactsToScale {
            return canReact
        }
        
        if parent != nil {
            return parent!.reactsToScale()
        }
        
        return nil
    }
}

