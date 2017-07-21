//
//  TechniqueSceneKitViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/23/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SceneKit
import FontAwesomeKit

class TechniqueSceneKitViewController: UIViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var hudView: CharacterHUDView!
    @IBOutlet weak var instructionView: InstructionView!
    @IBOutlet weak var backButton: UIButton!
    var animationToLoad: CharacterAnimationData?
    var loadWorkout = false
    
    internal var animationDatas: [CharacterAnimationData] = []
    internal var currentAnimationIndex = 0
    internal var sliderValue: Float = 0.5
    internal var instructionService: InstructionService?
    internal var virtualObjects: [VirtualObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeroEnabled = true
        // Do any additional setup after loading the view.
        if let hudView = hudView.view as? CharacterHUDView {
            hudView.delegate = self
        }
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        backButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        
        self.sceneView.scene = SCNScene()
        let male = Instructor()
        male.loadModel()
        virtualObjects.append(male)
        let target = male.armatureNode()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 1, z: 3)
        let constraint = SCNLookAtConstraint(target: target?.childNode(withName: "Hips", recursively: true))
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
        DispatchQueue.main.async {
            self.sceneView.scene?.rootNode.addChildNode(male)
            self.sceneView.scene?.rootNode.addChildNode(cameraNode)
            self.sceneView.scene?.rootNode.addChildNode(lightNode)
            self.sceneView.scene?.rootNode.addChildNode(ambientLightNode)
            
            
            // allows the user to manipulate the camera
            self.sceneView.pointOfView = cameraNode
            self.sceneView.allowsCameraControl = true
            
            // show statistics such as fps and timing information
            self.sceneView.showsStatistics = true
            
            // configure the view
            self.sceneView.backgroundColor = UIColor.black
            
            let alphaAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                self.view.alpha = 1
            })
            alphaAnimator.startAnimation()
        }
        
        if let currentAnimationData = animationToLoad {
            loadAnimation(currentAnimationData, speedScale: 1)
            startInstructionService(animationData: currentAnimationData)
        } else if loadWorkout {
            animationDatas = DataLoader.sharedInstance.characterAnimations()
            if animationDatas.count > 0 {
                loadAnimation(animationDatas[0], repeats: false, delegate: self)
                startInstructionService(animationData: animationDatas[0])
            }
        }
    }
    
    internal func startInstructionService(animationData: CharacterAnimationData) {
        if let instructionData = DataLoader.sharedInstance.instructionData(animationName: animationData.instructorAnimation) {
            instructionService?.stop()
            instructionService = InstructionService(instructionDataArray: instructionData, delegate: self)
            instructionService?.start(speed: Double(sliderValue * 2), timeOffset: 0)
        }
    }
    
    internal func resetInstructionService() {
        instructionView.removeAllLabels()
        instructionService?.stop()
    }

    @IBAction func onBackTap(_ sender: Any) {
        hero_unwindToRootViewController()
    }
    
    func updateCurrentAnimation() {
        if let currentAnimationData = currentAnimationData() {
            loadAnimation(currentAnimationData, speedScale: Double(sliderValue) * 2, removeHipTranslation: false, repeats: false, delegate: self)
            resetInstructionService()
            startInstructionService(animationData: animationDatas[currentAnimationIndex])
        }
    }
    
    func currentAnimationData() -> CharacterAnimationData? {
        if loadWorkout {
            if currentAnimationIndex < animationDatas.count {
                return animationDatas[currentAnimationIndex]
            }
        }
        return animationToLoad
    }
    
    func loadCurrentAnimationIndex() {
        if currentAnimationIndex < animationDatas.count {
            loadAnimation(animationDatas[currentAnimationIndex], speedScale: Double(sliderValue) * 2, repeats: false, delegate: self)
            startInstructionService(animationData: animationDatas[currentAnimationIndex])
        }
    }
    
    // MARK: - Virtual Objects
    
    func loadAnimation(_ animationData: CharacterAnimationData,
                       speedScale: Double? = nil,
                       removeHipTranslation: Bool = false,
                       repeats: Bool = true,
                       delegate: CAAnimationDelegate? = nil) {
        for object in virtualObjects {
            // load animation sequence
            // this replaces the dataload load animatino
            let animationSequenceData = AnimationSequenceData(instructorAnimation: animationData.instructorAnimation, ukeAnimation: animationData.ukeAnimation, delay: 0, speed: speedScale ?? 1, repeatCount: repeats ? Float.greatestFiniteMagnitude : 0)
            object.loadAnimationSequence(animationSequence: [animationSequenceData])
        }
    }
    
    func pauseVirtualObjects() {
        for object in virtualObjects {
            object.pauseAnimation()
        }
    }
    
    func resumeVirtualObjects() {
        for object in virtualObjects {
            object.resumeAnimation(speed: Double(sliderValue * 2))
        }
    }
}

extension TechniqueSceneKitViewController: CharacterHUDViewDelegate {
    func hudDidUpdateSlider(value: Float) {
        sliderValue = value
        updateCurrentAnimation()
    }
    
    func hudDidTapRewind() {
        currentAnimationIndex -= 1
        if currentAnimationIndex < 0 {
            currentAnimationIndex = animationDatas.count - 1
        }
        if loadWorkout {
            resetInstructionService()
            loadCurrentAnimationIndex()
        }
    }
    
    func hudDidTapPause() {
        pauseVirtualObjects()
        instructionView.removeAllLabels()
        instructionService?.pause()
    }
    
    func hudDidTapPlay() {
        resumeVirtualObjects()
        instructionService?.resume()
    }
    
    func hudDidTapShowToggle(shouldShow: Bool) {
    }
    
    func hudDidUpdateInstructorSwitch(isOn: Bool) {
    }
    
    func hudDidUpdateUkeSwitch(isOn: Bool) {
    }
}

extension TechniqueSceneKitViewController: InstructionServiceDelegate {
    func didUpdateInstruction(instruction: AnimationInstructionData) {
        print("instruction: \(instruction.text)")
        instructionView.addInstruction(text: instruction.text)
    }
}

extension TechniqueSceneKitViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        currentAnimationIndex += 1
        if currentAnimationIndex >= animationDatas.count {
            currentAnimationIndex = 0
        }
        
        if loadWorkout {
            loadCurrentAnimationIndex()
        }
    }
}
