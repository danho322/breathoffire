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
import SwiftySound

struct CharacterAnimationPickerConstants {
    
}

class CharacterAnimationPickerViewController: SpruceAnimatingViewController {

    @IBOutlet weak var sceneView: SCNView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadButton: UIButton!
    @IBOutlet weak var modeLabel: UILabel!
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var audioLabel: UILabel!
    @IBOutlet weak var audioSwitch: UISwitch!
    
    var packageName: String?
    var packageDescription: String?
    
    internal var sectionSequenceDict = Dictionary<String, [String]>()
    internal var sectionNames: [String] = []
    
    internal var model: VirtualObject?
    internal var sequenceToLoad: AnimationSequenceDataContainer?
    internal var sliderValue: Float = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        isHeroEnabled = false
        
        var sectionIndex = 0
        var rowIndex = 0
        var index: IndexPath?
        
        sectionNames = ["description"]
        sectionNames += DataLoader.sharedInstance.sequenceSections()
        for sectionName in sectionNames {
            if let sequenceRowArray = DataLoader.sharedInstance.sequenceRows(sectionName: sectionName) {
                if let packageName = packageName {

                    if let packageDetails = DataLoader.sharedInstance.package(packageName: packageName) {
                        packageDescription = packageDetails.packageDescription
                    }
                    
                    var filteredArray: [String] = []
                    for sequenceName in sequenceRowArray {
                        if let sequenceData = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName) {
                            if sequenceData.packageName == packageName {
                                filteredArray.append(sequenceName)
                                
                                if index == nil {
                                    index = IndexPath(row: rowIndex, section: sectionIndex)
                                }
                                rowIndex += 1
                            }
                        }
                    }
                    sectionSequenceDict[sectionName] = filteredArray
                } else {
                    sectionSequenceDict[sectionName] = sequenceRowArray
                }
            }
            sectionIndex += 1
            rowIndex = 0
        }
        
        let techniquesNib = UINib(nibName: String(describing: TechniqueTableCell.self), bundle: nil)
        tableView.register(techniquesNib , forCellReuseIdentifier: CellIdentifiers.Technique)
        tableView.register(UINib(nibName: String(describing: CharacterAnimationPickerDescriptionTableCell.self), bundle: nil), forCellReuseIdentifier: CharacterAnimationPickerDescriptionConstants.CellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.separatorColor = ThemeManager.sharedInstance.backgroundColor()
        
        loadButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        loadButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(14)
        loadButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        
        modeLabel.textColor = ThemeManager.sharedInstance.textColor()
        audioLabel.textColor = ThemeManager.sharedInstance.textColor()

        modeLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        
        modeSwitch.onTintColor = ThemeManager.sharedInstance.focusColor()
        audioSwitch.onTintColor = ThemeManager.sharedInstance.focusColor()

        audioSwitch.isOn = Sound.enabled
        
//        animations = [.slide(.up, .slightly), .fadeIn]
//        sortFunction = LinearSortFunction(direction: .topToBottom, interObjectDelay: 0.05)
//        animationView = tableView
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        
        self.sceneView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
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
            cameraNode.position = SCNVector3(x: 0, y: 0.5, z: 2.25)
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
                
                let alphaAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
                    self.view.alpha = 1
                })
                alphaAnimator.startAnimation()
                
                if let index = index {
                    self.tableView.selectRow(at: index, animated: true, scrollPosition: .none)
                    self.handleSelectRow(indexPath: index)
                }
            }
        }
    }
    
    @IBAction func onSwitchChange(_ sender: Any) {
    }
    
    @IBAction func onLoadTap(_ sender: Any) {
        
        Sound.enabled = audioSwitch.isOn
        
        if let arVC = storyboard?.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController {
            // TODO: disable these buttons on first run
            arVC.isARModeEnabled = modeSwitch.isOn
            arVC.sequenceToLoad = sequenceToLoad
            arVC.dismissCompletionHandler = { [unowned self] in
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
            self.present(arVC, animated: true, completion: nil)
        }
    }
    
    func handleSelectRow(indexPath: IndexPath) {
        if let sequenceContainer = sequenceDataContainer(indexPath: indexPath) {
            loadButton.isEnabled = true
            sequenceToLoad = sequenceContainer
            model?.loadAnimationSequence(animationSequence: sequenceContainer.sequenceArray)
        }
    }
    
//    refactor this to return container and then for everything to use this correctly
    func sequenceDataContainer(indexPath: IndexPath) -> AnimationSequenceDataContainer? {
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
        if section == 0 {
            return 1
        }
        
        let sequenceDict = sectionSequenceDict[sectionNames[section]]
        return sequenceDict?.count ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        description row
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CharacterAnimationPickerDescriptionConstants.CellIdentifier, for: indexPath)
            if let cell = cell as? CharacterAnimationPickerDescriptionTableCell {
                cell.packageNameLabel.text = packageName
                cell.packageDescriptionLabel.text = packageDescription
            }
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier:  CellIdentifiers.Technique, for: indexPath)
        if let cell = cell as? TechniqueTableCell {
            if let sequenceContainer = sequenceDataContainer(indexPath: indexPath) {
                cell.update(with: sequenceContainer.sequenceName)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        
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
        handleSelectRow(indexPath: indexPath)
    }
}
