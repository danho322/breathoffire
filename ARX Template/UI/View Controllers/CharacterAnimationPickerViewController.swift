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

struct CharacterAnimationPickerConstants {
    
}

class CharacterAnimationPickerViewController: SpruceAnimatingViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    
    var packageName: String?
    
    internal var sectionSequenceDict = Dictionary<String, [String]>()
    internal var sectionNames: [String] = []
    
    internal var model: VirtualObject?
    internal var sequenceToLoad: [AnimationSequenceData] = []
    internal var sliderValue: Float = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isHeroEnabled = false
        
        sectionNames = DataLoader.sharedInstance.sequenceSections()
        for sectionName in sectionNames {
            if let sequenceRowArray = DataLoader.sharedInstance.sequenceRows(sectionName: sectionName) {
                if let packageName = packageName {
                    var filteredArray: [String] = []
                    for sequenceName in sequenceRowArray {
                        if let sequenceData = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName) {
                            if sequenceData.packageName == packageName {
                                filteredArray.append(sequenceName)
                            }
                        }
                    }
                    sectionSequenceDict[sectionName] = filteredArray
                } else {
                    sectionSequenceDict[sectionName] = sequenceRowArray
                }
            }
        }
        
        let techniquesNib = UINib(nibName: String(describing: TechniqueTableCell.self), bundle: nil)
        tableView.register(techniquesNib , forCellReuseIdentifier: CellIdentifiers.Technique)
        
        tableView.dataSource = self
        tableView.delegate = self

        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.separatorColor = ThemeManager.sharedInstance.backgroundColor()
        
        loadButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        loadButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(14)
        loadButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        
        
//        animations = [.slide(.up, .slightly), .fadeIn]
//        sortFunction = LinearSortFunction(direction: .topToBottom, interObjectDelay: 0.05)
//        animationView = tableView
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        backButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        view.alpha = 0
        
        DispatchQueue.global().async {
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
                self.sceneView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
                
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
    
    @IBAction func onLoadTap(_ sender: Any) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sceneVC = segue.destination as? TechniqueSceneKitViewController, let identifier = segue.identifier, identifier == "TechniqueSegue" {
//            sceneVC.animationToLoad = currentAnimationData
        } else if let sceneVC = segue.destination as? ARTechniqueViewController, let identifier = segue.identifier, identifier == "ARSegue" {
                sceneVC.sequenceToLoad = sequenceToLoad
        }
    }
    
//    refactor this to return container and then for everything to use this correctly
    internal func sequenceDataArray(indexPath: IndexPath) -> AnimationSequenceDataContainer? {
        let sectionName = sectionNames[indexPath.section]
        if let sequenceArray = sectionSequenceDict[sectionName], let sequenceName = sequenceArray[safe: indexPath.row] {
            if let sequenceData = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName) {
                return sequenceData
            }
        }
        return nil
    }
}

// MARK: - UITableViewDataSource
extension CharacterAnimationPickerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sequenceDict = sectionSequenceDict[sectionNames[section]]
        return sequenceDict?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:  CellIdentifiers.Technique, for: indexPath)
        if let cell = cell as? TechniqueTableCell {
            if let sequenceContainer = sequenceDataArray(indexPath: indexPath) {
                cell.update(with: sequenceContainer.sequenceName)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let rowCount = sectionSequenceDict[sectionNames[section]]?.count ?? 0
        return rowCount > 0 ? 30 : CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionName = sectionNames[section]
        let rowCount = sectionSequenceDict[sectionName]?.count ?? 0
        if rowCount > 0 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 30))
            view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
            let label = UILabel(frame: CGRect(x: 10, y: 0, width: tableView.frame.size.width - 50, height: 30))
            label.backgroundColor = UIColor.clear
            label.textColor = ThemeManager.sharedInstance.labelTitleColor()
            label.font = ThemeManager.sharedInstance.defaultFont(14)
            label.text = sectionName
            view.addSubview(label)
            return view
        }
        return nil
    }
}

// MARK: - UITableViewDelegate
extension CharacterAnimationPickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sequenceContainer = sequenceDataArray(indexPath: indexPath) {
            loadButton.isEnabled = true
            sequenceToLoad = sequenceContainer.sequenceArray
            model?.loadAnimationSequence(animationSequence: sequenceContainer.sequenceArray)
        }
    }
}
