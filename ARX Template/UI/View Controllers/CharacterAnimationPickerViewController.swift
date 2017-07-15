//
//  CharacterAnimationPickerViewController.swift
//  SceneKitDemo
//
//  Created by Daniel Ho on 6/18/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Hero
import FontAwesomeKit
import Spruce

class CharacterAnimationPickerViewController: SpruceAnimatingViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    var model: VirtualObject?
    
    var sequenceToLoad: [AnimationSequenceData] = []
    var sliderValue: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeroEnabled = false
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        animations = [.slide(.up, .slightly), .fadeIn]
        sortFunction = LinearSortFunction(direction: .topToBottom, interObjectDelay: 0.05)
        animationView = tableView
        
        let loadIcon = FAKFoundationIcons.playIcon(withSize: 25)
        loadIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        
        loadButton.setAttributedTitle(loadIcon?.attributedString(), for: .normal)
        backButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        tableView.register(UINib(nibName: "TechniqueTableCell", bundle: nil), forCellReuseIdentifier: "TechniqueCell")
        view.alpha = 0
        
        DispatchQueue.global().async {
            // retrieve the SCNView
            // hack to test animation
//            self.sceneView.scene = SCNScene(named: "Models.scnassets/jiujitsu/JiujitsuModel.dae")!
//            let target = self.sceneView.scene!.rootNode.childNode(withName: "Armtr", recursively: true)

            self.sceneView.scene = SCNScene()
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
            DispatchQueue.main.async {
                self.sceneView.scene?.rootNode.addChildNode(male)
                self.sceneView.scene?.rootNode.addChildNode(cameraNode)
                self.sceneView.scene?.rootNode.addChildNode(lightNode)
                self.sceneView.scene?.rootNode.addChildNode(ambientLightNode)
                
                
                // allows the user to manipulate the camera
                self.sceneView.pointOfView = cameraNode
                
                // show statistics such as fps and timing information
                self.sceneView.showsStatistics = true
                
                // configure the view
                self.sceneView.backgroundColor = UIColor.black
                
                let alphaAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                    self.view.alpha = 1
                })
                alphaAnimator.startAnimation()
            }
        }
    }

    @IBAction func onBackTap(_ sender: Any) {
        hero_dismissViewController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sceneVC = segue.destination as? TechniqueSceneKitViewController, let identifier = segue.identifier, identifier == "TechniqueSegue" {
//            sceneVC.animationToLoad = currentAnimationData
        } else if let sceneVC = segue.destination as? ARTechniqueViewController, let identifier = segue.identifier, identifier == "ARSegue" {
                sceneVC.sequenceToLoad = sequenceToLoad
        }
    }
    
    internal func sequenceDataArray(indexPath: IndexPath) -> [AnimationSequenceData]? {
        if let sectionName = DataLoader.sharedInstance.sequenceSections()[safe: indexPath.section],
            let sequenceRowArray = DataLoader.sharedInstance.sequenceRows(sectionName: sectionName),
            let sequenceName = sequenceRowArray[safe: indexPath.row] {
            let dataContainer = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName)
            return dataContainer?.sequenceArray
        }
        return nil
    }
}

// MARK: - UITableViewDataSource
extension CharacterAnimationPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionName = DataLoader.sharedInstance.sequenceSections()[safe: section],
            let sequenceRowArray = DataLoader.sharedInstance.sequenceRows(sectionName: sectionName) {
                return sequenceRowArray.count
        }
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return DataLoader.sharedInstance.sequenceSections().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TechniqueCell", for: indexPath)
        if let cell = cell as? TechniqueTableCell {
            if let sectionName = DataLoader.sharedInstance.sequenceSections()[safe: indexPath.section],
                let sequenceRowArray = DataLoader.sharedInstance.sequenceRows(sectionName: sectionName),
                let sequenceName = sequenceRowArray[safe: indexPath.row] {
                cell.titleLabel.text = sequenceName
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataLoader.sharedInstance.sequenceSections()[safe: section] ?? ""
    }
}

// MARK: - UITableViewDelegate
extension CharacterAnimationPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         // trying to debug what is happening with keyframes not loading on simulator
//        var animation: CAAnimation?
//        if let scene = SCNScene(named: "Models.scnassets/jiujitsu/Perception.dae") {
//            scene.rootNode.enumerateChildNodes({ (child, stop) in
//                if child.animationKeys.count > 0 {
//                    animation = child.animation(forKey: child.animationKeys.first!)
//                    stop.initialize(to: true)
//                }
//            })
//        }
//        if let animationGroup = animation as? CAAnimationGroup, let animations = animationGroup.animations {
//            for subanimation in animations {
//                if let keyframeAnimation = subanimation as? CAKeyframeAnimation {
//                    print(keyframeAnimation.keyPath)
//                    if let nodePath = keyframeAnimation.keyPath?.replacingOccurrences(of: "/", with: "") {
//                        let nodeName = nodePath.replacingOccurrences(of: ".transform", with: "")
//                        if let node = sceneView.scene!.rootNode.childNode(withName: nodeName, recursively: true) {
//                            keyframeAnimation.keyPath = "transform"
//                            print(keyframeAnimation.values)
//                            node.addAnimation(keyframeAnimation, forKey: "\(nodeName)Animation")
//                        }
//                    }
//                }
//            }
//        }

        // this works on device
//        let armtr = sceneView.scene!.rootNode.childNode(withName: "Armtr", recursively: true)
//        armtr?.addAnimation(animation!, forKey: "messi")
//        print(armtr)
//        return
        
        
        
        
        if let sequenceDataArray = sequenceDataArray(indexPath: indexPath) {
            sequenceToLoad = sequenceDataArray
            model?.loadAnimationSequence(animationSequence: sequenceDataArray)
        }
    }
}
