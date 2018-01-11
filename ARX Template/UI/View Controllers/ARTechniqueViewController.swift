/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import Foundation
import SceneKit
import UIKit
import Photos
import FontAwesomeKit
import Instructions

struct ARTechniqueConstants {
    static let SessionTimerInterval: TimeInterval = 0.1
}

class ARTechniqueViewController: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var breathTimerView: BreathTimerView!
    @IBOutlet weak var instructionView: InstructionView!
    var walkthroughVC: BWWalkthroughViewController?
    
    @IBOutlet weak var hudView: CharacterHUDView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageViewContainer: UIView!
    @IBOutlet weak var hudBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var currentAnimationLabel: UILabel!
    @IBOutlet weak var currentAnimationTimeLabel: UILabel!
    @IBOutlet weak var showPortalButton: UIButton!
    @IBOutlet weak var hidePortalButton: UIButton!
    @IBOutlet weak var toggleBreathButton: UIButton!
    @IBOutlet weak var nextAnimationButton: UIButton!
    
    var isARModeEnabled = true
    var sequenceToLoad: AnimationSequenceDataContainer?
    var dismissCompletionHandler: (()->Void)?
    
    internal var currentAnimationIndex = 0
    internal var currentAnimationTimer: Timer?
    
    internal var sliderValue: Float = 0.5
    
    internal let placingCoachMarksController = CoachMarksController()
    internal let techniqueCoachMarksController = CoachMarksController()
    internal var instructionService: InstructionService?
    internal var breathTimerService: BreathTimerService?
    internal var sessionTimer: Timer?
    internal var sessionCounter: TimeInterval = 0
    
    internal var virtualObjects: [VirtualObject] = []
    internal var currentPlacementState: ARObjectPlacementState = .ScanningEmpty
    internal weak var relatedAnimationsView: RelatedAnimationsView?

    internal var hasSetupLights = false
    internal var physicsPlane: SCNNode?
    internal var hasSetupViewController = false
    internal var portal: PortalRoomObject?
    
    // live session
    var liveSessionInfo = LiveSessionInfo(type: .none, liveSession: nil, intention: nil)
    internal var liveSessionCounter: TimeInterval = 0
    internal var liveSessionKey: String?
    internal var joinedUserNames: [String] = []
    
    // feed
    internal var screenShot: [UIImage] = []
    
    // touch
    internal var initialTouchPosition: CGPoint?
    
    // physics
    internal var ball: SCNNode?
    
    // MARK: - Main Setup & View Controller methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Constants.isSimulator {
            isARModeEnabled = false
        }

        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        
        placingCoachMarksController.dataSource = self
        placingCoachMarksController.delegate = self
        placingCoachMarksController.overlay.color = ThemeManager.sharedInstance.backgroundColor(alpha: 0.8)
        placingCoachMarksController.overlay.allowTap = true
        
        techniqueCoachMarksController.dataSource = self
        techniqueCoachMarksController.delegate = self
        techniqueCoachMarksController.overlay.color = ThemeManager.sharedInstance.backgroundColor(alpha: 0.8)
        techniqueCoachMarksController.overlay.allowTap = true
        
        if let hudView = hudView.view as? CharacterHUDView {
            hudView.delegate = self
        }
        breathTimerView.hideBreathUI(true)
        
        #if DEBUG
            currentAnimationLabel.isHidden = false
            currentAnimationTimeLabel.isHidden = false
            settingsButton.isHidden = false
            messagePanel.isHidden = false
            showPortalButton.isHidden = false
            hidePortalButton.isHighlighted = false
            nextAnimationButton.isHidden = false
            toggleBreathButton.isHidden = false
        #else
            currentAnimationLabel.isHidden = true
            currentAnimationTimeLabel.isHidden = true
            settingsButton.isHidden = true
            messagePanel.isHidden = true
            showPortalButton.isHidden = true
            hidePortalButton.isHidden = true
            nextAnimationButton.isHidden = true
            toggleBreathButton.isHidden = true
        #endif
    }
    
    func setupViewControllerTechnique() {
        Setting.registerDefaults()
        sceneView.isHidden = !isARModeEnabled
        setupUIControls()
        hudDidTapShowToggle(shouldShow: false)
        if isARModeEnabled {
            setupScene()
            setupDebug()
            setupFocusSquare()
            updateSettings()
            resetVirtualObject()
            setupGestureRecognizers()
            restartPlaneDetection()
        } else {
            let instructorType: InstructorType = sequenceToLoad?.instructorType ?? .generic
            let characterScene0 = ARXCharacterSceneView(frame: sceneView.frame, cameraPosition: SCNVector3(x: 0, y: 0.3, z: 2), instructorType: instructorType)
            view.insertSubview(characterScene0, aboveSubview: sceneView)
            if let model = characterScene0.model {
                model.delegate = self
                virtualObjects.append(model)
            }
        }
        
        updatePlacementUI()
        
        if let sequenceToLoad = sequenceToLoad {
            breathTimerView.hideBreathUI(true)
            breathTimerView.updateAlpha(0)
            
            instructionService = InstructionService(delegate: self)
        }
        
        if !isARModeEnabled {
            startTechnique()
        }
        
        hasSetupViewController = true
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
		
		// Start the ARSession.
        
        if isARModeEnabled && hasSetupViewController {
            restartPlaneDetection()
        }
        
        if !hasSetupViewController {
            onViewWillAppear()
        }
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		session.pause()
        cancelScreenshotSelector()
        
        placingCoachMarksController.stop(immediately: true)
        techniqueCoachMarksController.stop(immediately: true)
	}

    @IBAction func onNextAnimationTap(_ sender: Any) {
        for object in virtualObjects {
            object.skipCurrentAnimation()
        }
    }
    
    // MARK: - Starting session
    
    fileprivate func onViewWillAppear() {
        if SessionManager.sharedInstance.shouldShowTutorial(type: .ARWalkthrough) {
            displayWalkthrough()
        } else {
          displayGetReady()
        }
    }
    
    fileprivate func displayWalkthrough() {
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "walk") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewController(withIdentifier: "arwalk0")
        let page_one = stb.instantiateViewController(withIdentifier: "arwalk1")
        let page_two = stb.instantiateViewController(withIdentifier: "arwalk2")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController:page_zero)
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthroughVC = walkthrough
        present(walkthrough, animated: true, completion: nil)
    }
    
    fileprivate func displayGetReady() {
        if !isARModeEnabled {
            let message = isARModeEnabled ?
                "Point the phone camera ahead of you toward the floor." :
            "Find a comfortable place for your practice."
            let alert = UIAlertController(title: "Get Ready", message: message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(
                UIAlertAction(title: "Ok",
                              style: UIAlertActionStyle.default,
                              handler: { [unowned self] _ in
                                self.setupViewControllerTechnique()
                    }
                )
            )
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = self.view.bounds
            }
            self.present(alert, animated: true, completion: nil)
        } else {
            setupViewControllerTechnique()
        }
    }
    
    // MARK: - Live Sessions
    
    func startLiveSession() {
        liveSessionKey = LiveSessionManager.sharedInstance.startLiveSession(intention: liveSessionInfo.intention ?? "", sequenceName: sequenceToLoad?.sequenceName ?? "", delegate: self)
    }
    
    func joinLiveSession(key: String?) {
        liveSessionKey = key
        if let key = key {
            LiveSessionManager.sharedInstance.joinLiveSession(key: key, delegate: self)
        }
    }
    
    func pingLiveSession() {
        LiveSessionManager.sharedInstance.pingCurrentLiveSession(key: liveSessionKey)
    }
    
    func removeUserAvatar(userName: String) {
        if let userNode = sceneView.scene.rootNode.childNode(withName: userName, recursively: true) {
            userNode.removeFromParentNode()
        }
    }
    
    @objc func addUserAvatar(userName: String) {
        if let virtualObject = virtualObjects.first {
            let incrementX: Float = 0.08
            let incrementY: Float = 0.05
            let randX = Float(arc4random_uniform(10)) * incrementX - (10 * incrementX)
            let randY = Float(arc4random_uniform(15)) * incrementY
//            let randZ = Float(arc4random_uniform(5)) * incrementX
            
            let (direction, _) = getUserVector()
            
            let position = SCNVector3(virtualObject.position.x + randX * direction.x, virtualObject.position.y + randY * direction.y, virtualObject.position.z + direction.z * 2)
            let textNode = addTextToScene("\(userName) joined", position: position, eulerAngles: virtualObject.eulerAngles, fontSize: 0.1, fontColor: ThemeManager.sharedInstance.secondaryFocusForegroundColor())
            
            SCNTransaction.animationDuration = 10.0
            textNode.position = SCNVector3(x: position.x, y: position.y + 1, z: position.z)
            textNode.opacity = 0
        }
    }
    
    func addIntentionToScene() {
        if let liveSessionIntention = liveSessionInfo.intention {
            if let virtualObject = virtualObjects.first {
                
                let (direction, _) = getUserVector()
                
                let position = SCNVector3(virtualObject.position.x + direction.x, virtualObject.position.y + direction.y, virtualObject.position.z + direction.z * 5)
                
                addTextToScene(liveSessionIntention, position: position, eulerAngles: virtualObject.eulerAngles, fontSize: 0.3, fontColor: ThemeManager.sharedInstance.focusForegroundColor())
            }
        }
    }
    
    internal func addTextToScene(_ text: String, position: SCNVector3, eulerAngles: SCNVector3, fontSize: CGFloat, fontColor: UIColor) -> SCNNode {
        let annotationNode = SCNNode()
        
        var v1 = SCNVector3(x: 0,y: 0,z: 0)
        var v2 = SCNVector3(x: 0,y: 0,z: 0)
        
        let sDepth: CGFloat = fontSize / 10
        let newText = SCNText(string: text, extrusionDepth: sDepth)
        newText.font = UIFont (name: "AvenirNext-Regular", size: fontSize)
        newText.isWrapped = true
        newText.firstMaterial!.diffuse.contents = fontColor
        newText.firstMaterial!.specular.contents = fontColor
        print(newText.boundingBox)

        let textNode = SCNNode(geometry: newText)
        v1 = textNode.boundingBox.min
        v2 = textNode.boundingBox.max
        let dx:Float = Float(v1.x - v2.x)/2.0
        let dy:Float = Float(v1.y - v2.y)
        textNode.position = SCNVector3Make(dx, dy, Float(sDepth/2))
        
        annotationNode.addChildNode(textNode)
        annotationNode.name = text
        annotationNode.position = position
        sceneView.scene.rootNode.addChildNode(annotationNode)
        
        annotationNode.eulerAngles = eulerAngles
        
        return annotationNode
    }
    
    // MARK: - Breathe
    
    internal func setupBreathing(animationData: CharacterAnimationData) {
        print("setupBreathing")
        breathTimerService?.stop()
        if let breathProgram = animationData.breathProgram {
            print("setup program")
            breathTimerService = BreathTimerService(breathProgram: breathProgram, delegate: self)
            breathTimerView.updateAlpha(0.8)
            breathTimerView.hideBreathUI(false)
        } else {
            breathTimerView.updateAlpha(0)
        }
    }
    
    @IBAction func onToggleBreathTap(_ sender: Any) {
        breathTimerView.isHidden = !breathTimerView.isHidden
    }
    // MARK: - Feed
    
    func saveToBreathFeed(rating: Int?, comment: String?, screenShotArray: [UIImage]) {
        var index = 0
        var uploadCount = 0
        let uploadTotal = screenShot.count
        var pathDict: [Int: String] = Dictionary<Int, String>()
        if screenShotArray.count > 0 {
            for image in screenShotArray {
                let data = UIImageJPEGRepresentation(image, GifConstants.GifImageCompressionQuality)
                let thisIndex = index
                FirebaseService.sharedInstance.uploadFeedData(data: data) { [unowned self] path in
                    if let path = path {
                        pathDict[thisIndex] = path
                        let pathArray = pathDict.sorted(by: { $0.key < $1.key}).map({ $0.value })
                        uploadCount += 1
                        print("\(uploadCount) out of \(uploadTotal)")
                        if uploadCount == uploadTotal {
                            self.executeShareSaveWithLocation(rating: rating, comment: comment, pathArray: pathArray)
                        }
                    } else {
                        print("an upload error ocurred")
                    }
                }
                index += 1
            }
        } else {
            executeShareSaveWithLocation(rating: rating, comment: comment, pathArray: [])
        }
    }
    
    internal var hasSent = false
    internal func executeShareSaveWithLocation(rating: Int?, comment: String?, pathArray: [String]) {
        if hasSent {
            return
        }
        hasSent = true
        if let currentUserData = SessionManager.sharedInstance.currentUserData {
            // add to feed path
            ARXLocationService.sharedInstance.retrieveUserLocation(userData: currentUserData, handler: { coordinate in
                let feedItem = BreathFeedItem(timestamp: Date().timeIntervalSince1970,
                                              imagePathArray: pathArray,
                                              userId: currentUserData.userId,
                                              userName: currentUserData.userName,
                                              breathCount: self.breathTimerView.currentBreathCount(),
                                              city: currentUserData.city,
                                              coordinate: coordinate,
                                              rating: rating,
                                              comment: comment)
                FirebaseService.sharedInstance.saveBreathFeedItem(feedItem)
            })
        }
    }
    
    // MARK: - Ball
    
    internal func calculateBallTrajectoryAndThrow(_ touchDiff: CGPoint) {
        if let cameraPos = sceneView.pointOfView?.position, let virtualObjectPos = virtualObjects.first?.position {
            let velocity = SCNVector3(virtualObjectPos.x - cameraPos.x, 3, virtualObjectPos.z - cameraPos.z)
            
            //                        TODO: this has to do with the angle?
            let (direction, position) = getUserVector()
            
            let scale = max(1.0, -0.013 * Double(touchDiff.y))
            
            throwBall(position: SCNVector3(position.x, position.y, position.z),
                      velocity: SCNVector3(direction.x * Float(scale), velocity.y, direction.z * Float(scale)))
            
        }
    }
    
    internal func throwBall(position: SCNVector3, velocity: SCNVector3 = SCNVector3Zero) {
        removeBall()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(removeBall), object: nil)
        
        
        guard let pineappleScene = SCNScene(named: "pineapple.dae", inDirectory: "Models.scnassets") else {
            return
        }
        
        let ballGeom = SCNSphere(radius:0.02)
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 0)
        ballMaterial.specular.contents = UIColor.clear
        ballGeom.firstMaterial = ballMaterial
        ball = SCNNode(geometry:ballGeom)
        
        ball!.physicsBody = SCNPhysicsBody.dynamic()
        ball!.physicsBody?.mass = 0.5
        ball!.physicsBody?.restitution = 0.4
//        ball!.physicsBody?.angularVelocity = SCNVector4(random)
        ball!.physicsBody?.velocity = velocity
        ball!.position = position
        
        let wrapperNode = SCNNode()
        
        for child in pineappleScene.rootNode.childNodes {
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            child.movabilityHint = .movable
            wrapperNode.addChildNode(child)
        }
        ball!.addChildNode(wrapperNode)

        sceneView.scene.rootNode.addChildNode(ball!)
        
        perform(#selector(removeBall), with: nil, afterDelay: 5)
    }
    
    @objc internal func removeBall() {
        ball?.removeFromParentNode()
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir, pos)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    // MARK: - Gestures
    
    func setupGestureRecognizers() {
        view.isMultipleTouchEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ARTechniqueViewController.handleTap))
        tap.numberOfTapsRequired = 2
        sceneView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
//        print("handleTap")
//        let tapPoint = recognizer.location(in: sceneView)
//        let result = sceneView.hitTest(tapPoint, types: .estimatedHorizontalPlane)
//        if let hitResult = result.first {
//            print("hit result")
//            if currentPlacementState == .PlacedReady {
//                throwBall(position: SCNVector3(x: hitResult.worldTransform.columns.3.x,
//                                               y: hitResult.worldTransform.columns.3.y + 3,
//                                               z: hitResult.worldTransform.columns.3.z))
//            } else if virtualObjects.count == 0 && currentPlacementState.isPlacingAllowed() {
//                loadVirtualObject(at: SCNVector3(x: hitResult.worldTransform.columns.3.x,
//                                                 y: hitResult.worldTransform.columns.3.y,
//                                                 z: hitResult.worldTransform.columns.3.z))
//                currentPlacementState = .PlacedScaling
//                updatePlacementUI()
//            }
//        }
    }
    
    // MARK: - Placing Object
    
    internal func updatePlacementUI() {
        if isARModeEnabled {
            if !currentPlacementState.isPlaced() {
                planes.forEach({ anchor, plane in
                    if plane.anchor.extent.x > 0.3 && plane.anchor.extent.z > 0.3 && focusSquare?.lastPosition != nil {
                        chooseObject(nil)   // automatically place!
                    }
                })
                
//                if currentPlacementState == .ScanningReady {
//                    if SessionManager.sharedInstance.shouldShowTutorial(type: .ARTechnique) {
//                        placingCoachMarksController.start(on: self)
//                    }
//                }
            }
            
            statusLabel.text = DataLoader.sharedInstance.textForPlacementState(currentPlacementState)
            for subview in statusImageViewContainer.subviews {
                subview.removeFromSuperview()
            }
            if let view = DataLoader.sharedInstance.viewForPlacementState(currentPlacementState) {
                statusImageViewContainer.addSubview(view)
                view.center = CGPoint(x: statusImageViewContainer.frame.size.width / 2, y: statusImageViewContainer.frame.size.height / 2)
            }
            statusLabel.isHidden = currentPlacementState.hideStatusLabel()
            statusImageViewContainer.isHidden = statusLabel.isHidden
            addObjectButton.isHidden = currentPlacementState.hideAddButton()
            
            let showHud = sequenceToLoad?.showHud ?? false
            hudView.isHidden = !currentPlacementState.isPlaced() || !showHud
            
            screenshotButton.isHidden = !currentPlacementState.isPlaced()
            endButton.isHidden = !currentPlacementState.hideStatusLabel()
            exitButton.isHidden = currentPlacementState.hideStatusLabel()
            restartExperienceButton.isHidden = !currentPlacementState.showDebugVisuals()
            
            let shouldShowDebugVisuals = currentPlacementState.showDebugVisuals()
            if showDebugVisuals != shouldShowDebugVisuals {
                showDebugVisuals = shouldShowDebugVisuals
            }
        } else {
            statusLabel.text = nil
            statusLabel.isHidden = true
            statusImageViewContainer.isHidden = statusLabel.isHidden
            addObjectButton.isHidden = true
            hudView.isHidden = true
            
        }
    }
    
    internal func startCharacterAnimations() {
        guard let object = virtualObjects.first else {
            return
        }
        
        guard let sequenceToLoad = sequenceToLoad else {
            return
        }
        
        DispatchQueue.global().async {
            var uke: Uke?
            if object is Instructor && !self.virtualObjects.contains(where: { ($0 is Uke) }) {
                uke = Uke()
                uke!.viewController = self
                uke!.loadModel()
                self.virtualObjects.append(uke!)
            }
            
            DispatchQueue.main.async {
                object.instructionService = self.instructionService
                object.loadAnimationSequence(animationSequence: sequenceToLoad.sequenceArray)
                if let uke = uke {
                    self.setVirtualObject(object: uke, at: object.position)
                    uke.scale = object.scale
                    uke.eulerAngles.y = object.eulerAngles.y
                }
                
                self.virtualObjects.filter({ $0 is Uke }).forEach({ object in
                    object.loadAnimationSequence(animationSequence: sequenceToLoad.sequenceArray)
                })
            }
        }
    }
    
    // MARK: - Instruction Service
    
    internal func createNewInstructionService(animationData: CharacterAnimationData) {
        if let instructionData = DataLoader.sharedInstance.instructionData(animationName: animationData.instructorAnimation) {
            instructionService?.stop()
            instructionService = InstructionService(instructionDataArray: instructionData, delegate: self)
        }
    }
    
    internal func resetInstructionService() {
        instructionView.removeAllLabels()
        instructionService?.stop()
    }
    
    
    // MARK: - Virtual Objects
    
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
	
    // MARK: - ARKit / ARSCNView
    let session = ARSession()
    var sessionConfig: ARWorldTrackingConfiguration = ARWorldTrackingConfiguration()
	var use3DOFTracking = false {
		didSet {
			if use3DOFTracking {
				sessionConfig = ARWorldTrackingConfiguration()
			}
			sessionConfig.isLightEstimationEnabled = UserDefaults.standard.bool(for: .ambientLightEstimation)
			session.run(sessionConfig)
		}
	}
	var use3DOFTrackingFallback = false
    @IBOutlet var sceneView: ARSCNView!
	var screenCenter: CGPoint?
    
    func setupScene() {
        // set up sceneView
//        sceneView.debugOptions = [.showPhysicsShapes]
        sceneView.delegate = self
        sceneView.session = session
		sceneView.antialiasingMode = .multisampling4X
		sceneView.automaticallyUpdatesLighting = false
		
		sceneView.preferredFramesPerSecond = 60
		sceneView.contentScaleFactor = 1.3
		//sceneView.showsStatistics = true
		
		enableEnvironmentMapWithIntensity(25.0)
		
		DispatchQueue.main.async {
			self.screenCenter = self.sceneView.bounds.mid
		}
		
		if let camera = sceneView.pointOfView?.camera {
			camera.wantsHDR = true
			camera.wantsExposureAdaptation = true
			camera.exposureOffset = -1
			camera.minimumExposure = -1
		}
    }
	
	func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
		if sceneView.scene.lightingEnvironment.contents == nil {
			if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
				sceneView.scene.lightingEnvironment.contents = environmentMap
			}
		}
		sceneView.scene.lightingEnvironment.intensity = intensity
	}
	
    // MARK: - ARSCNViewDelegate
	
	func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if !currentPlacementState.isPlaced() {
            refreshFeaturePoints()
        }
		
		DispatchQueue.main.async {
			self.updateFocusSquare()
			self.hitTestVisualization?.render()
			
			// If light estimation is enabled, update the intensity of the model's lights and the environment map
			if let lightEstimate = self.session.currentFrame?.lightEstimate {
				self.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 40)
			} else {
				self.enableEnvironmentMapWithIntensity(25)
			}
		}
	}
	
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if !currentPlacementState.isUpdatePlanesAllowed() {
            return
        }
        
        DispatchQueue.main.async {
            self.currentPlacementState = .ScanningProgress
            if let planeAnchor = anchor as? ARPlaneAnchor {
				self.addPlane(node: node, anchor: planeAnchor)
                self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
            }
            self.updatePlacementUI()
        }
    }
	
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if !currentPlacementState.isUpdatePlanesAllowed() {
            return
        }
        
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.updatePlane(anchor: planeAnchor)
                self.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor)
            }
            self.updatePlacementUI()
        }
    }
	
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if !currentPlacementState.isUpdatePlanesAllowed() {
            return
        }
        
        DispatchQueue.main.async {
            if let planeAnchor = anchor as? ARPlaneAnchor {
                self.removePlane(anchor: planeAnchor)
            }
            self.updatePlacementUI()
        }
    }
	
	var trackingFallbackTimer: Timer?

	func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: !self.showDebugVisuals)

        switch camera.trackingState {
        case .notAvailable:
            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 5.0)
        case .limited:
            if use3DOFTrackingFallback {
                // After 10 seconds of limited quality, fall back to 3DOF mode.
                trackingFallbackTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false, block: { _ in
                    self.use3DOFTracking = true
                    self.trackingFallbackTimer?.invalidate()
                    self.trackingFallbackTimer = nil
                })
            } else {
                textManager.escalateFeedback(for: camera.trackingState, inSeconds: 10.0)
            }
        case .normal:
            textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
            if use3DOFTrackingFallback && trackingFallbackTimer != nil {
                trackingFallbackTimer!.invalidate()
                trackingFallbackTimer = nil
            }
        }
	}
	
    func session(_ session: ARSession, didFailWithError error: Error) {

        guard let arError = error as? ARError else { return }

        let nsError = error as NSError
		var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
		if let recoveryOptions = nsError.localizedRecoveryOptions {
			for option in recoveryOptions {
				sessionErrorMsg.append("\(option).")
			}
		}

        let isRecoverable = (arError.code == .worldTrackingFailed)
		if isRecoverable {
			sessionErrorMsg += "\nYou can try resetting the session or quit the application."
		} else {
			sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
		}
		cancelScreenshotSelector()
		displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
	}
	
	func sessionWasInterrupted(_ session: ARSession) {
        instructionService?.stop()
        cancelScreenshotSelector()
		textManager.blurBackground()
		textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
	}
		
	func sessionInterruptionEnded(_ session: ARSession) {
		textManager.unblurBackground()
		session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
		restartExperience(self)
		textManager.showMessage("RESETTING SESSION")
	}
	
    // MARK: - Ambient Light Estimation
	
	func toggleAmbientLightEstimation(_ enabled: Bool) {
		
        if enabled {
			if !sessionConfig.isLightEstimationEnabled {
				// turn on light estimation
				sessionConfig.isLightEstimationEnabled = true
				session.run(sessionConfig)
			}
        } else {
			if sessionConfig.isLightEstimationEnabled {
				// turn off light estimation
				sessionConfig.isLightEstimationEnabled = false
				session.run(sessionConfig)
			}
        }
    }

    // MARK: - Gesture Recognizers
	
	var currentGesture: Gesture?
    var currentTouchesSet: Set<UITouch> = Set()
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesBegan: \(touches.count)")
        super.touchesBegan(touches, with: event)
        
        touches.forEach({ [unowned self] touch in
            self.currentTouchesSet.insert(touch)
        })
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(delayedTouchesBegan), object: nil)
        self.perform(#selector(delayedTouchesBegan), with: nil, afterDelay: 0.2)
	}
    
    @objc fileprivate func delayedTouchesBegan() {
        for object in virtualObjects {
            if currentGesture == nil {
                currentGesture = Gesture.startGestureFromTouches(currentTouchesSet, self.sceneView, object, currentPlacementState)
            } else {
                currentGesture = currentGesture!.updateGestureFromTouches(currentTouchesSet, .touchBegan)
            }
        }
        
        displayVirtualObjectTransform()
        initialTouchPosition = currentTouchesSet.first?.location(in: sceneView)
    }
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
		if virtualObjects.count == 0 {
			return
		}
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
		displayVirtualObjectTransform()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touchesEnded")
        super.touchesEnded(touches, with: event)
        
//        if virtualObjects.count == 0 && currentPlacementState.isPlacingAllowed() {
//            chooseObject(addObjectButton)
//            return
//        }
		
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
        if let latestTouchPosition = touches.first?.location(in: sceneView) {
            if currentPlacementState == .PlacedReady {
                if let initialTouchPosition = initialTouchPosition {
                    let diff = CGPoint(x: latestTouchPosition.x - initialTouchPosition.x, y: latestTouchPosition.y - initialTouchPosition.y)
                    print("diff: \(diff)")
                    if diff.y < 0 {
                        
                        // refactor this into own method
                        calculateBallTrajectoryAndThrow(diff)
                    }
                }
            } else {
                
            }
        }
        
        touches.forEach({ [unowned self] touch in
            self.currentTouchesSet.remove(touch)
        })
    }
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
		if virtualObjects.count == 0 {
			return
		}
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchCancelled)
	}
	
	// MARK: - Virtual Object Manipulation
	
	func displayVirtualObjectTransform() {
		
		guard  let cameraTransform = session.currentFrame?.camera.transform else {
			return
		}
		
		// Output the current translation, rotation & scale of the virtual object as text.
        var distance = ""
        var scale = ""
        var angleDegrees = 0
		let cameraPos = SCNVector3.positionFromTransform(cameraTransform)
        for object in virtualObjects {
            let vectorToCamera = cameraPos - object.position
            
            let distanceToUser = vectorToCamera.length()
            
            angleDegrees = Int(((object.eulerAngles.y) * 180) / Float.pi) % 360
            if angleDegrees < 0 {
                angleDegrees += 360
            }
            
            distance = String(format: "%.2f", distanceToUser)
            scale = String(format: "%.2f", object.scale.x)
        }
		textManager.showDebugMessage("Distance: \(distance) m\nRotation: \(angleDegrees)°\nScale: \(scale)x")
	}
	
	func moveVirtualObjectToPosition(_ pos: SCNVector3?, _ instantly: Bool, _ filterPosition: Bool) {
		guard let newPosition = pos else {
			textManager.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
			// Reset the content selection in the menu only if the content has not yet been initially placed.
			if virtualObjects.count == 0 {
				resetVirtualObject()
			}
			return
		}
		
		if instantly {
			setNewVirtualObjectPosition(newPosition)
		} else {
			updateVirtualObjectPosition(newPosition, filterPosition)
		}
	}
	
	var dragOnInfinitePlanesEnabled = false
	
	func worldPositionFromScreenPosition(_ position: CGPoint,
	                                     objectPos: SCNVector3?,
	                                     infinitePlane: Bool = false) -> (position: SCNVector3?, planeAnchor: ARPlaneAnchor?, hitAPlane: Bool) {
		
		// -------------------------------------------------------------------------------
		// 1. Always do a hit test against exisiting plane anchors first.
		//    (If any such anchors exist & only within their extents.)
		
		let planeHitTestResults = sceneView.hitTest(position, types: .existingPlaneUsingExtent)
		if let result = planeHitTestResults.first {
			
			let planeHitTestPosition = SCNVector3.positionFromTransform(result.worldTransform)
			let planeAnchor = result.anchor
			
			// Return immediately - this is the best possible outcome.
			return (planeHitTestPosition, planeAnchor as? ARPlaneAnchor, true)
		}
		
		// -------------------------------------------------------------------------------
		// 2. Collect more information about the environment by hit testing against
		//    the feature point cloud, but do not return the result yet.
		
		var featureHitTestPosition: SCNVector3?
		var highQualityFeatureHitTestResult = false
		
		let highQualityfeatureHitTestResults = sceneView.hitTestWithFeatures(position, coneOpeningAngleInDegrees: 18, minDistance: 0.2, maxDistance: 2.0)
		
		if !highQualityfeatureHitTestResults.isEmpty {
			let result = highQualityfeatureHitTestResults[0]
			featureHitTestPosition = result.position
			highQualityFeatureHitTestResult = true
		}
		
		// -------------------------------------------------------------------------------
		// 3. If desired or necessary (no good feature hit test result): Hit test
		//    against an infinite, horizontal plane (ignoring the real world).
		
		if (infinitePlane && dragOnInfinitePlanesEnabled) || !highQualityFeatureHitTestResult {
			
			let pointOnPlane = objectPos ?? SCNVector3Zero
			
			let pointOnInfinitePlane = sceneView.hitTestWithInfiniteHorizontalPlane(position, pointOnPlane)
			if pointOnInfinitePlane != nil {
				return (pointOnInfinitePlane, nil, true)
			}
		}
		
		// -------------------------------------------------------------------------------
		// 4. If available, return the result of the hit test against high quality
		//    features if the hit tests against infinite planes were skipped or no
		//    infinite plane was hit.
		
		if highQualityFeatureHitTestResult {
			return (featureHitTestPosition, nil, false)
		}
		
		// -------------------------------------------------------------------------------
		// 5. As a last resort, perform a second, unfiltered hit test against features.
		//    If there are no features in the scene, the result returned here will be nil.
		
		let unfilteredFeatureHitTestResults = sceneView.hitTestWithFeatures(position)
		if !unfilteredFeatureHitTestResults.isEmpty {
			let result = unfilteredFeatureHitTestResults[0]
			return (result.position, nil, false)
		}
		
		return (nil, nil, false)
	}
	
	// Use average of recent virtual object distances to avoid rapid changes in object scale.
	var recentVirtualObjectDistances = [CGFloat]()
	
    func setNewVirtualObjectPosition(_ pos: SCNVector3) {
	
		guard let cameraTransform = session.currentFrame?.camera.transform else {
			return
		}
		
		recentVirtualObjectDistances.removeAll()
		
		let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
		var cameraToPosition = pos - cameraWorldPos
		
		// Limit the distance of the object from the camera to a maximum of 10 meters.
		cameraToPosition.setMaximumLength(10)
        
        for object in virtualObjects {
            setVirtualObject(object: object, at: cameraWorldPos + cameraToPosition)
        }
    }
    
    func setupShadowLightsIfNeeded(target: SCNNode) {
        if hasSetupLights {
            physicsPlane?.position = target.position
            return
        }
        hasSetupLights = true
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        lightNode.light?.shadowMode = .deferred
        lightNode.light?.castsShadow = true
        lightNode.position = SCNVector3(x: target.position.x, y: target.position.y + 20, z: target.position.z + 8)
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        // Points directional light at target
        let constraint = SCNLookAtConstraint(target: target)
        lightNode.constraints = [constraint]
        
        let omniLightNode = SCNNode()
        omniLightNode.light = SCNLight()
        omniLightNode.light?.type = .omni
        omniLightNode.position = SCNVector3(x: target.position.x, y: target.position.y + 20, z: target.position.z)
        sceneView.scene.rootNode.addChildNode(omniLightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)  // Set this to what the environment light is
        sceneView.scene.rootNode.addChildNode(ambientLightNode)
        
        let planeGeo = SCNPlane(width: 15, height: 15)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.white
        planeMaterial.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        planeGeo.materials = [planeMaterial]
        
        physicsPlane = SCNNode(geometry: planeGeo)
        physicsPlane!.rotation = SCNVector4Make(1, 0, 0, -Float(Double.pi / 2));
        physicsPlane!.position = SCNVector3(target.position.x, target.position.y, target.position.z)
        
        // this should provide collision
        physicsPlane!.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static,
                                               shape: SCNPhysicsShape(geometry: planeGeo, options: nil))
        sceneView.scene.rootNode.addChildNode(physicsPlane!)
    }
    
    func setVirtualObject(object: VirtualObject, at pos: SCNVector3) {
        print("setVirtualObject \(object) at \(pos)")
        object.position = pos
        
        setupShadowLightsIfNeeded(target: object)

        if object.parent == nil {
            sceneView.scene.rootNode.addChildNode(object)
        }
    }

	func resetVirtualObject() {
        for virtualObject in virtualObjects {
            virtualObject.unloadModel()
            virtualObject.removeFromParentNode()
        }
        virtualObjects.removeAll()
		
		addObjectButton.setImage(#imageLiteral(resourceName: "add"), for: [])
		addObjectButton.setImage(#imageLiteral(resourceName: "addPressed"), for: [.highlighted])
        
		// Reset selected object id for row highlighting in object selection view controller.
		UserDefaults.standard.set(-1, for: .selectedObjectID)
	}
	
	func updateVirtualObjectPosition(_ pos: SCNVector3, _ filterPosition: Bool) {
		guard let cameraTransform = session.currentFrame?.camera.transform else {
			return
		}
		
		let cameraWorldPos = SCNVector3.positionFromTransform(cameraTransform)
		var cameraToPosition = pos - cameraWorldPos
		
		// Limit the distance of the object from the camera to a maximum of 10 meters.
		cameraToPosition.setMaximumLength(10)
		
		// Compute the average distance of the object from the camera over the last ten
		// updates. If filterPosition is true, compute a new position for the object
		// with this average. Notice that the distance is applied to the vector from
		// the camera to the content, so it only affects the percieved distance of the
		// object - the averaging does _not_ make the content "lag".
		let hitTestResultDistance = CGFloat(cameraToPosition.length())

		recentVirtualObjectDistances.append(hitTestResultDistance)
		recentVirtualObjectDistances.keepLast(10)
        
        for object in virtualObjects {
            if filterPosition {
                let averageDistance = recentVirtualObjectDistances.average!
                
                cameraToPosition.setLength(Float(averageDistance))
                let averagedDistancePos = cameraWorldPos + cameraToPosition
                
                object.position = averagedDistancePos
            } else {
                object.position = cameraWorldPos + cameraToPosition
            }
            setupShadowLightsIfNeeded(target: object)
        }
    }
	
	func checkIfObjectShouldMoveOntoPlane(anchor: ARPlaneAnchor) {
		guard let planeAnchorNode = sceneView.node(for: anchor) else {
			return
		}
        
        for object in virtualObjects {
            // Get the object's position in the plane's coordinate system.
            let objectPos = planeAnchorNode.convertPosition(object.position, from: object.parent)
            
            if objectPos.y == 0 {
                return; // The object is already on the plane - nothing to do here.
            }
            
            // Add 10% tolerance to the corners of the plane.
            let tolerance: Float = 0.1
            
            let minX: Float = anchor.center.x - anchor.extent.x / 2 - anchor.extent.x * tolerance
            let maxX: Float = anchor.center.x + anchor.extent.x / 2 + anchor.extent.x * tolerance
            let minZ: Float = anchor.center.z - anchor.extent.z / 2 - anchor.extent.z * tolerance
            let maxZ: Float = anchor.center.z + anchor.extent.z / 2 + anchor.extent.z * tolerance
            
            if objectPos.x < minX || objectPos.x > maxX || objectPos.z < minZ || objectPos.z > maxZ {
                return
            }
            
            // Drop the object onto the plane if it is near it.
            let verticalAllowance: Float = 0.03
            if objectPos.y > -verticalAllowance && objectPos.y < verticalAllowance {
                textManager.showDebugMessage("OBJECT MOVED\nSurface detected nearby")
                
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                object.position.y = anchor.transform.columns.3.y
                SCNTransaction.commit()
            }
        }
	}
	
    // MARK: - Virtual Object Loading
	
	var isLoadingObject: Bool = false {
		didSet {
			DispatchQueue.main.async {
				self.addObjectButton.isEnabled = !self.isLoadingObject
				self.screenshotButton.isEnabled = !self.isLoadingObject
				self.restartExperienceButton.isEnabled = !self.isLoadingObject
			}
		}
	}
	
	@IBOutlet weak var addObjectButton: UIButton!
	
	func loadVirtualObject(at pos: SCNVector3) {
		resetVirtualObject()
		
		// Show progress indicator
		let spinner = UIActivityIndicatorView()
		spinner.center = addObjectButton.center
		spinner.bounds.size = CGSize(width: addObjectButton.bounds.width - 5, height: addObjectButton.bounds.height - 5)
		addObjectButton.setImage(#imageLiteral(resourceName: "buttonring"), for: [])
		sceneView.addSubview(spinner)
		spinner.startAnimating()
		
		// Load the content asynchronously.
		DispatchQueue.global().async {
			self.isLoadingObject = true
            let object = Instructor(type: self.sequenceToLoad?.instructorType)
			object.viewController = self
            object.delegate = self
            
			object.loadModel()
            object.loadIdleAnimation()
            self.virtualObjects.append(object)
            
            DispatchQueue.main.async {
                // Immediately place the object in 3D space.
				self.setNewVirtualObjectPosition(pos)
				
				// Remove progress indicator
				spinner.removeFromSuperview()
				
				// Update the icon of the add object button
                let thumbImage = FAKFoundationIcons.checkIcon(withSize: 15).image(with: self.addObjectButton.frame.size)!
                
				let buttonImage = UIImage.composeButtonImage(from: thumbImage)
				let pressedButtonImage = UIImage.composeButtonImage(from: thumbImage, alpha: 0.3)
				self.addObjectButton.setImage(buttonImage, for: [])
				self.addObjectButton.setImage(pressedButtonImage, for: [.highlighted])
				self.isLoadingObject = false
			}
		}
        
        SessionManager.sharedInstance.onPlay()
    }
	
	@IBAction func chooseObject(_ sender: Any?) {
        print("chooseObject")
		// Abort if we are about to load another object to avoid concurrent modifications of the scene.
		if isLoadingObject { return }
		
		textManager.cancelScheduledMessage(forType: .contentPlacement)
		
        if !currentPlacementState.isPlaced() {
            var pos = SCNVector3Zero
            if let lastFocusSquarePos = self.focusSquare?.lastPosition {
                pos = lastFocusSquarePos
            }
            loadVirtualObject(at: pos)
            currentPlacementState = .PlacedEditing
        } else if currentPlacementState == .PlacedEditing {
            currentPlacementState = .PlacedReady

            //DH: do we want to stop plane detection?
//            stopPlaneDetection()
            hitTestVisualization?.remove()
            showHitTestAPIVisualization = false
            
            scheduleScreenshot()
            
            startTechnique()
        }
        updatePlacementUI()
    }
    
    func startTechnique() {
        // hardcode setup for now
        startCharacterAnimations()
        
        if SessionManager.sharedInstance.shouldShowTutorial(type: .ARTechnique) {
            techniqueCoachMarksController.start(on: self)
        }
        
        sessionCounter = 0
        setupSessionTimer(speedMultipler: sliderValue * 2)
        
        if liveSessionInfo.type == .create {
            startLiveSession()
        } else if liveSessionInfo.type == .join {
            joinLiveSession(key: liveSessionInfo.liveSession?.key)
        }
        addIntentionToScene()
//        //testing
//        perform(#selector(testAddUser(index:)), with: "0", afterDelay: 5)
//        perform(#selector(testAddUser(index:)), with: "1", afterDelay: 10)
//        perform(#selector(testAddUser(index:)), with: "2", afterDelay: 15)
//        perform(#selector(testAddUser(index:)), with: "3", afterDelay: 20)
//        perform(#selector(testAddUser(index:)), with: "4", afterDelay: 25)
//        perform(#selector(testAddUser(index:)), with: "5", afterDelay: 30)
        
    }
    
    @objc func testAddUser(index: String) {
        if index == "0" {
            onUserJoined(userName: "Anonymous", userCount: 1)
        } else if index == "1" {
            onUserJoined(userName: "Denny Prokopos", userCount: 2)
        } else if index == "2" {
            onUserJoined(userName: "Anonymous", userCount: 3)
        } else if index == "3" {
            onUserJoined(userName: "Daniel Ho", userCount: 4)
        } else if index == "4" {
            onUserJoined(userName: "Anonymous", userCount: 5)
        } else if index == "5" {
            onUserJoined(userName: "Jakub Burkot", userCount: 6)
        }
    }
    
    internal func setupSessionTimer(speedMultipler: Float) {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: ARTechniqueConstants.SessionTimerInterval / Double(speedMultipler), repeats: true, block: { [unowned self] _ in
            self.currentAnimationTimeLabel.text = "\(self.sessionCounter)s"
            self.sessionCounter += ARTechniqueConstants.SessionTimerInterval
            self.breathTimerView.updateTimeLabel(self.sessionCounter)
            
            self.liveSessionCounter += ARTechniqueConstants.SessionTimerInterval
            if self.liveSessionCounter >= LiveSession.PingFrequency {
                self.liveSessionCounter = 0
                self.pingLiveSession()
            }
        })
    }
    
    // MARK: - Screenshot
    
    func scheduleScreenshot() {
        let randSec = TimeInterval(arc4random_uniform(30))
        
        let frames = GifConstants.FrameCount
        let interval: TimeInterval = GifConstants.FrameDelay
        for index in 1...frames {
            perform(#selector(ARTechniqueViewController.captureScreenshot), with: nil, afterDelay: 10 + randSec + TimeInterval(index) * interval)
        }
    }
    
    func cancelScreenshotSelector() {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(ARTechniqueViewController.captureScreenshot), object: nil)
    }
    
    @objc func captureScreenshot() {
        let image = sceneView.snapshot()
        screenShot.append(image)
    }
	
    // MARK: - Planes
	
	var planes = [ARPlaneAnchor: Plane]()
	
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
		print("ADD PLANE")
		let pos = SCNVector3.positionFromTransform(anchor.transform)
		textManager.showDebugMessage("NEW SURFACE DETECTED AT \(pos.friendlyString())")
        
		let plane = Plane(anchor, showDebugVisuals)
		
		planes[anchor] = plane
		node.addChildNode(plane)
		
		textManager.cancelScheduledMessage(forType: .planeEstimation)
		textManager.showMessage("SURFACE DETECTED")
		if virtualObjects.count == 0 {
			textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
		}
	}
		
    func updatePlane(anchor: ARPlaneAnchor) {
        if let plane = planes[anchor] {
            print("UPDATE PLANE")
			plane.update(anchor)
		}
	}
			
    func removePlane(anchor: ARPlaneAnchor) {
		if let plane = planes.removeValue(forKey: anchor) {
			plane.removeFromParentNode()
        }
    }
	
	func restartPlaneDetection() {
		
		// configure session
        sessionConfig.planeDetection = .horizontal
        session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
		
		// reset timer
		if trackingFallbackTimer != nil {
			trackingFallbackTimer!.invalidate()
			trackingFallbackTimer = nil
		}
		
		textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
		                            inSeconds: 7.5,
		                            messageType: .planeEstimation)
	}
    
    func stopPlaneDetection() {
        // pause() freezes the camera
        sessionConfig.planeDetection = .init(rawValue: 0)
        session.run(sessionConfig, options: [.resetTracking, .removeExistingAnchors])
    }
    

    // MARK: - Focus Square
    var focusSquare: FocusSquare?
	
    func setupFocusSquare() {
		focusSquare?.isHidden = true
		focusSquare?.removeFromParentNode()
		focusSquare = FocusSquare()
		sceneView.scene.rootNode.addChildNode(focusSquare!)
		
		textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
	
	func updateFocusSquare() {
		guard let screenCenter = screenCenter else { return }

        let hideSquare = currentPlacementState.isPlaced()
        let moveObject = currentPlacementState.isMovingAllowed()
		if hideSquare {
            focusSquare?.hide()
        } else {
            focusSquare?.unhide()
        }
		let (worldPos, planeAnchor, hitAPlane) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
		if let worldPos = worldPos {
			focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
            if moveObject {
                moveVirtualObjectToPosition(worldPos, false, hitAPlane)
            }
			textManager.cancelScheduledMessage(forType: .focusSquare)
		}
	}
    
    // MARK: - Portal
    
    @IBAction func onShowPortalTap(_ sender: Any) {
        if let virtualObject = virtualObjects.first {
            addPortal(position: virtualObject.position)
        }
    }
    
    @IBAction func onHidePortalTap(_ sender: Any) {
        removePortal()
    }
    
    func removePortal() {
        portal?.removeFromParentNode()
    }
    
    func addPortal(position: SCNVector3) {
        removePortal()
        
        portal = PortalRoomObject()
        portal!.position = SCNVector3(position.x, position.y /*- Float(Nodes.WALL_WIDTH / 2)*/, position.z)
        sceneView.scene.rootNode.addChildNode(portal!)
    }
	
	// MARK: - Hit Test Visualization
	
	var hitTestVisualization: HitTestVisualization?
	
	var showHitTestAPIVisualization = UserDefaults.standard.bool(for: .showHitTestAPI) {
		didSet {
			UserDefaults.standard.set(showHitTestAPIVisualization, for: .showHitTestAPI)
			if showHitTestAPIVisualization {
				hitTestVisualization = HitTestVisualization(sceneView: sceneView)
			} else {
				hitTestVisualization = nil
			}
		}
	}
	
    // MARK: - Debug Visualizations
	
	@IBOutlet var featurePointCountLabel: UILabel!
	
	func refreshFeaturePoints() {
		guard showDebugVisuals else {
			return
		}
		
		// retrieve cloud
		guard let cloud = session.currentFrame?.rawFeaturePoints else {
			return
		}
		
		DispatchQueue.main.async {
			self.featurePointCountLabel.text = "Features: \(cloud.__count)".uppercased()
		}
	}
	
    var showDebugVisuals: Bool = UserDefaults.standard.bool(for: .debugMode) {
        didSet {
			featurePointCountLabel.isHidden = !showDebugVisuals
			debugMessageLabel.isHidden = !showDebugVisuals
			planes.values.forEach { $0.showDebugVisualization(showDebugVisuals) }
			
			if showDebugVisuals {
				sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
			} else {
				sceneView.debugOptions = []
			}
			
            // save pref
            UserDefaults.standard.set(showDebugVisuals, for: .debugMode)
        }
    }
    
    func setupDebug() {
		// Set appearance of debug output panel
		messagePanel.layer.cornerRadius = 3.0
		messagePanel.clipsToBounds = true
    }
    
    // MARK: - UI Elements and Actions
	
	@IBOutlet weak var messagePanel: UIView!
	@IBOutlet weak var messageLabel: UILabel!
	@IBOutlet weak var debugMessageLabel: UILabel!
	
	var textManager: TextManager!
	
    func setupUIControls() {
        let closeIcon = FAKIonIcons.closeIcon(withSize: 25)
        closeIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
        exitButton.setAttributedTitle(closeIcon?.attributedString(), for: .normal)
        
        endButton.setTitle("Finish", for: .normal)
        endButton.titleLabel?.font = ThemeManager.sharedInstance.defaultFont(16)
        endButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        endButton.layer.borderColor = ThemeManager.sharedInstance.focusForegroundColor().cgColor
        endButton.layer.borderWidth = 1
        endButton.layer.cornerRadius = 10
        endButton.layer.masksToBounds = true
        
        textManager = TextManager(viewController: self)
		
        // hide debug message view
		debugMessageLabel.isHidden = true
		
		featurePointCountLabel.text = ""
		debugMessageLabel.text = ""
		messageLabel.text = ""
    }
	
	@IBOutlet weak var restartExperienceButton: UIButton!
	var restartExperienceButtonIsEnabled = true
	
	@IBAction func restartExperience(_ sender: Any) {
		
		guard restartExperienceButtonIsEnabled, !isLoadingObject else {
			return
		}
		
		DispatchQueue.main.async {
			self.restartExperienceButtonIsEnabled = false
			
			self.textManager.cancelAllScheduledMessages()
			self.textManager.dismissPresentedAlert()
			self.textManager.showMessage("STARTING A NEW SESSION")
			self.use3DOFTracking = false
			
            self.updateSettings()
			self.setupFocusSquare()
			self.resetVirtualObject()
			
            self.planes.forEach({ key, value in
                value.removeFromParentNode()
            })
            self.planes.removeAll()
            self.restartPlaneDetection()
            
            self.currentPlacementState = .ScanningEmpty
            self.updatePlacementUI()
			
			self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])

            self.cancelScreenshotSelector()
			
			// Disable Restart button for five seconds in order to give the session enough time to restart.
			DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
				self.restartExperienceButtonIsEnabled = true
			})
		}
	}
	
	@IBOutlet weak var screenshotButton: UIButton!
	
	@IBAction func takeScreenshot() {
		guard screenshotButton.isEnabled else {
			return
		}
		
		let takeScreenshotBlock = {
			UIImageWriteToSavedPhotosAlbum(self.sceneView.snapshot(), nil, nil, nil)
			DispatchQueue.main.async {
				// Briefly flash the screen.
				let flashOverlay = UIView(frame: self.sceneView.frame)
				flashOverlay.backgroundColor = UIColor.white
				self.sceneView.addSubview(flashOverlay)
				UIView.animate(withDuration: 0.25, animations: {
					flashOverlay.alpha = 0.0
				}, completion: { _ in
					flashOverlay.removeFromSuperview()
				})
			}
		}
		
		switch PHPhotoLibrary.authorizationStatus() {
		case .authorized:
			takeScreenshotBlock()
		case .restricted, .denied:
			let title = "Photos access denied"
			let message = "Please enable Photos access for this application in Settings > Privacy to allow saving screenshots."
			textManager.showAlert(title: title, message: message)
		case .notDetermined:
			PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
				if authorizationStatus == .authorized {
					takeScreenshotBlock()
				}
			})
		}
	}
    
    @IBAction func onExitTap(_ sender: Any) {
        let alertMessage = UIAlertController(title: NSLocalizedString("Exit Session?", comment: "Action sheet title"),
                                             message: nil,
                                             preferredStyle: .actionSheet)
        
        
        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Exit", comment: "Ok button title"), style: .default, handler: { [unowned self] _ in
            self.dismiss()
        }))
        
        alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] _ in
            self.hudDidTapPlay()
        }))
        
        alertMessage.popoverPresentationController?.sourceView = endButton
        alertMessage.popoverPresentationController?.sourceRect = endButton.frame
        alertMessage.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        if let popoverPresentationController = alertMessage.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    @IBAction func onEndTap(_ sender: Any) {
        hudDidTapPause()
        let breathTime = sessionCounter
        let alertMessage = UIAlertController(title: NSLocalizedString("End Session?", comment: "Action sheet title"),
                                             message: nil,
                                             preferredStyle: .actionSheet)
        
        
        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("End", comment: "Ok button title"), style: .default, handler: { [unowned self] _ in
            self.finishSequence(object: self.virtualObjects.first!, timeBreathed: breathTime)
        }))
        
        alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [unowned self] _ in
            self.hudDidTapPlay()
        }))
        
        alertMessage.popoverPresentationController?.sourceView = endButton
        alertMessage.popoverPresentationController?.sourceRect = endButton.frame
        alertMessage.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        if let popoverPresentationController = alertMessage.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    func stopTechniqueServices() {
        instructionService?.stop()
        cancelScreenshotSelector()
        breathTimerService?.stop()
    }
    
    func finishSequence(object: VirtualObject, timeBreathed: TimeInterval? = nil) {
        print("finished with sequence \(object.animationSequence)")
        stopTechniqueServices()
        
        var breathTime = breathTimerService?.breathProgram.sessionTime ?? 0
        if let timeBreathed = timeBreathed {
            breathTime = timeBreathed
        }
        
        if let last = object.animationSequence.last {
            if let data = DataLoader.sharedInstance.characterAnimation(name: last.instructorAnimation) {
                SessionManager.sharedInstance.onPlayFinish(breathTimeInterval: breathTime)
                
                
                checkUpsellLogin() { [unowned self] in
                    let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: Sizes.ScreenHeight)
                    
                    
                    // TODO: sequence container should have a state on what completion view to show
                    
                    //                let relatedView = RelatedAnimationsView(frame: frame)
                    //                relatedView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
                    //                relatedView.relatedAnimations = data.relatedAnimations ?? []
                    //                relatedView.set(delegate: self)
                    //                view.addSubview(relatedView)
                    //                relatedView.animateIn()
                    //                relatedAnimationsView = relatedView
                    let breathCompletionView = BreatheCompleteView(frame: frame,
                                                                   parentVC: self,
                                                                   shareCommunityHandler: { [unowned self] didShare, rating, comment in
                                                                    let imageArray = didShare ? self.screenShot : []
                                                                    self.saveToBreathFeed(rating: rating, comment: comment, screenShotArray:
imageArray)
                        },
                                                                   dismissHandler: {
                                                                    self.dismiss()
                    })
                    breathCompletionView.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height / 2)
                    
                    let breathDuration = BreathTimerService.timeString(time: breathTime)
                    var shareText = "I finished a session with the Breath of Fire app! \(Constants.AppStoreLink)"
                    var detailText = "Total time: \(breathDuration)"
                    
                    if let animationSequenceData = self.sequenceToLoad {
                        shareText = "I finished \(animationSequenceData.sequenceName) using the Breath of Fire app! \(Constants.AppStoreLink)"
                        detailText = "\(animationSequenceData.sequenceName) completed"
                        
                        if self.joinedUserNames.count == 1 {
                            shareText = "I used the Breath of Fire app to CONNECT TO THE UNIVERSE! \(Constants.AppStoreLink)"
                            detailText = "\(animationSequenceData.sequenceName) completed\nwith \(self.joinedUserNames[0])"
                        } else if self.joinedUserNames.count > 1 {
                            shareText = "\(self.joinedUserNames.joined(separator: ", ")) and I used the Breath of Fire app to CONNECT TO THE UNIVERSE! \(Constants.AppStoreLink)"
                            var names = self.joinedUserNames.joined(separator: ", ")
                            if let lastName = self.joinedUserNames.last {
                                names = names.replacingOccurrences(of: ", \(lastName)", with: " and \(lastName)")
                                detailText = "\(animationSequenceData.sequenceName) completed\nwith \(names)"
                            }
                        }
                    }
                    
                    
                    breathCompletionView.update(detailsText: detailText, shareText: shareText, screenshot: self.screenShot, sequenceContainer: nil)
                    self.view.addSubview(breathCompletionView)
                    breathCompletionView.animateIn()
                }
            }
        }
    }
    
    internal func checkUpsellLogin(completion: @escaping ()->Void) {
        if SessionManager.sharedInstance.shouldShowUpsellLogin() {
            SessionManager.sharedInstance.presentLogin(on: self) { [unowned self] in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func dismiss() {
        self.dismiss(animated: true) { [unowned self] in
            self.dismissCompletionHandler?()
        }
    }
		
	// MARK: - Settings
	
	@IBOutlet weak var settingsButton: UIButton!
	
	@IBAction func showSettings(_ button: UIButton) {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "ARSettingsViewController") as? ARSettingsViewController else {
			return
		}
		
		let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
		settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
		settingsViewController.title = "Options"
		
		let navigationController = UINavigationController(rootViewController: settingsViewController)
		navigationController.modalPresentationStyle = .popover
		navigationController.popoverPresentationController?.delegate = self
		navigationController.preferredContentSize = CGSize(width: sceneView.bounds.size.width - 20, height: sceneView.bounds.size.height - 50)
		self.present(navigationController, animated: true, completion: nil)
		
		navigationController.popoverPresentationController?.sourceView = settingsButton
		navigationController.popoverPresentationController?.sourceRect = settingsButton.bounds
	}
	
    @objc
    func dismissSettings() {
		self.dismiss(animated: true, completion: nil)
		updateSettings()
	}
	
	private func updateSettings() {
		let defaults = UserDefaults.standard
		
		showDebugVisuals = defaults.bool(for: .debugMode)
		toggleAmbientLightEstimation(defaults.bool(for: .ambientLightEstimation))
		dragOnInfinitePlanesEnabled = defaults.bool(for: .dragOnInfinitePlanes)
		showHitTestAPIVisualization = defaults.bool(for: .showHitTestAPI)
		use3DOFTracking	= defaults.bool(for: .use3DOFTracking)
		use3DOFTrackingFallback = defaults.bool(for: .use3DOFFallback)
		for (_, plane) in planes {
			plane.updateOcclusionSetting()
		}
	}

	// MARK: - Error handling
	
	func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
		// Blur the background.
		textManager.blurBackground()
		
		if allowRestart {
			// Present an alert informing about the error that has occurred.
			let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
				self.textManager.unblurBackground()
				self.restartExperience(self)
			}
			textManager.showAlert(title: title, message: message, actions: [restartAction])
		} else {
			textManager.showAlert(title: title, message: message, actions: [])
		}
	}
	
	// MARK: - UIPopoverPresentationControllerDelegate
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return .none
	}
	
	func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
		updateSettings()
	}
}

extension ARTechniqueViewController: LiveSessionDelegate {
    func onUserJoined(userName: String, userCount: Int) {
        
        var nameToAdd = userName
        
        var i = 1
        while joinedUserNames.contains(nameToAdd) {
            nameToAdd = "\(userName) \(i)"
            i += 1
        }
        joinedUserNames.append(nameToAdd)
        addUserAvatar(userName: nameToAdd)
    }
}

extension ARTechniqueViewController: CharacterHUDViewDelegate {
    func hudDidUpdateSlider(value: Float) {
        sliderValue = value
        for object in virtualObjects {
            object.updateAnimationSpeed(speed: Double(value * 2))
        }
        setupSessionTimer(speedMultipler: sliderValue)
    }
    
    func hudDidTapRewind() {
        for object in virtualObjects {
            object.rewind()
        }
    }
    
    func hudDidTapPause() {
        sessionTimer?.invalidate()
        pauseVirtualObjects()
        instructionView.removeAllLabels()
        instructionService?.pause()
        breathTimerService?.pause()
    }
    
    func hudDidTapPlay() {
        setupSessionTimer(speedMultipler: sliderValue * 2)
        resumeVirtualObjects()
        instructionService?.resume()
        breathTimerService?.resume()
    }
    
    func hudDidUpdateInstructorSwitch(isOn: Bool) {
        virtualObjects.filter({ $0 is Instructor }).forEach({ $0.isHidden = !isOn })
    }
    
    func hudDidUpdateUkeSwitch(isOn: Bool) {
        virtualObjects.filter({ $0 is Uke }).forEach({ $0.isHidden = !isOn })
    }
    
    func hudDidTapShowToggle(shouldShow: Bool) {
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut, animations: {
            self.settingsButton.alpha = shouldShow ? 0 : 1
            self.screenshotButton.alpha = shouldShow ? 0 : 1
            self.hudBottomConstraint.constant = shouldShow ? -120 : -40
            self.view.layoutIfNeeded()
            
            })
        animator.startAnimation()
    }
}

extension ARTechniqueViewController: InstructionServiceDelegate {
    func didUpdateInstruction(instruction: AnimationInstructionData) {
        instructionView.addInstruction(text: instruction.text)
    }
}

extension ARTechniqueViewController: VirtualObjectDelegate {
    func virtualObjectDidUpdateAnimation(_ object: VirtualObject, animationData: CharacterAnimationData) {
        setupBreathing(animationData: animationData)
        
        currentAnimationLabel.text = "\(object.currentAnimationIndex): \(animationData.instructorAnimation): \(animationData.animationDuration())"
    }
    
    func virtualObjectDidFinishAnimation(_ object: VirtualObject) {
        currentAnimationTimer?.invalidate()
    }
    
    func virtualObjectDidFinishAnimationSequence(_ object: VirtualObject) {
        finishSequence(object: object)
    }
}

extension ARTechniqueViewController: RelatedAnimationsViewDelegate {
    func didTapRelatedAnimation(relatedView: RelatedAnimationsView, sequenceName: String) {
        relatedAnimationsView?.animateOut()

        sequenceToLoad = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName)
        startCharacterAnimations()
    }
    
    func didTapShare(relatedView: RelatedAnimationsView) {
        
    }
    
    func didTapDismiss(relatedView: RelatedAnimationsView) {
        relatedAnimationsView?.animateOut()
        hero_dismissViewController()
    }
    
    func didTapReplay(relatedView: RelatedAnimationsView) {
        self.relatedAnimationsView?.animateOut()
        self.relatedAnimationsView = nil
        startCharacterAnimations()
    }
}

extension ARTechniqueViewController: BreathTimerServiceDelegate {
    func breathTimerDidTick(timestamp: TimeInterval, nextParameterTimestamp: TimeInterval, currentParameter: BreathProgramParameter?) {
        breathTimerView.update(timestamp: timestamp, nextParameterTimestamp: nextParameterTimestamp, breathParameter: currentParameter, sessionTimestamp: sessionCounter)
    }
    
    func breathTimeDidStart() {
        breathTimerView.handleStart()
    }
    
    func breathTimeDidFinish() {
        breathTimerView.finishTimer()
    }
}

extension ARTechniqueViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - Tutorial

enum PlacingInstructionType: Int {
    case placeButton = 0
    case count = 1
    
    func view(vc: ARTechniqueViewController) -> UIView? {
        switch self {
        case .placeButton:
            return vc.addObjectButton
        default:
            return nil
        }
    }
    
    func hintText() -> String {
        switch self {
        case .placeButton:
            return "When reay, tap here to place your instructor"
        default:
            return ""
        }
    }
}

enum TechniqueInstructionType: Int {
    case hudButton = 0
    case cameraButton = 1
    case count = 2
    
    func view(vc: ARTechniqueViewController) -> UIView? {
        switch self {
        case .hudButton:
            return vc.hudView
        case .cameraButton:
            return vc.screenshotButton
        default:
            return nil
        }
    }
    
    func hintText() -> String {
        switch self {
        case .hudButton:
            return "Access controls to play/pause/edit your technique animation"
        case .cameraButton:
            return "Snap a picture of your session"
        default:
            return ""
        }
    }
    
    func shouldShow(vc: ARTechniqueViewController) -> Bool {
        switch self {
        case .hudButton:
            return !vc.hudView.isHidden
        default:
            return true
        }
    }
}

extension ARTechniqueViewController: CoachMarksControllerDataSource {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        if coachMarksController === placingCoachMarksController {
            return PlacingInstructionType.count.rawValue
        } else {
            return TechniqueInstructionType.count.rawValue
        }
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        var view = TechniqueInstructionType(rawValue: index)?.view(vc: self)
        if coachMarksController === placingCoachMarksController {
            view = PlacingInstructionType(rawValue: index)?.view(vc: self)
        }
        print("make coach mark for \(view)")
        return coachMarksController.helper.makeCoachMark(for: view)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        var hintText = TechniqueInstructionType(rawValue: index)?.hintText()
        if coachMarksController === placingCoachMarksController {
            hintText = PlacingInstructionType(rawValue: index)?.hintText()
        }
        
        coachViews.bodyView.hintLabel.text = hintText ?? ""
        coachViews.bodyView.nextLabel.text = "Ok"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}

extension ARTechniqueViewController: CoachMarksControllerDelegate {
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willLoadCoachMarkAt index: Int) -> Bool {
        if coachMarksController === techniqueCoachMarksController {
            return TechniqueInstructionType(rawValue: index)?.shouldShow(vc: self) ?? true
        }
        return true
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willShow coachMark: inout CoachMark,
                              afterSizeTransition: Bool,
                              at index: Int) {
        print("willShow at: \(index), afterSizeTransition: \(afterSizeTransition)")
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didShow coachMark: CoachMark,
                              afterSizeTransition: Bool,
                              at index: Int) {
        print("didShow at: \(index), afterSizeTransition: \(afterSizeTransition)")
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              willHide coachMark: CoachMark,
                              at index: Int) {
        print("willHide at: \(index)")
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didHide coachMark: CoachMark,
                              at index: Int) {
        print("didHide at: \(index)")
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              didEndShowingBySkipping skipped: Bool) {
        print("didEndShowingBySkipping: \(skipped)")
        if !skipped {
            if coachMarksController === techniqueCoachMarksController {
                SessionManager.sharedInstance.onTutorialShow(type: .ARTechnique)
            }
        }
    }
    
    func shouldHandleOverlayTap(in coachMarksController: CoachMarksController, at index: Int) -> Bool {
        print("shoudlHandleOverlay")
        return true
    }
}

// MARK: - Walkthrough
extension ARTechniqueViewController: BWWalkthroughViewControllerDelegate {
    func walkthroughCloseButtonPressed() {
        SessionManager.sharedInstance.onTutorialShow(type: .ARWalkthrough)
        
        walkthroughVC?.dismiss(animated: true, completion: nil)
        
        displayGetReady()
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        print("now at \(pageNumber)")
        walkthroughVC?.closeButton?.isHidden = pageNumber != 2
    }
}
