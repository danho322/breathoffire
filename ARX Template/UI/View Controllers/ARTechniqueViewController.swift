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


class ARTechniqueViewController: UIViewController, ARSCNViewDelegate, UIPopoverPresentationControllerDelegate, VirtualObjectSelectionViewControllerDelegate {
    
    @IBOutlet weak var instructionView: InstructionView!
    @IBOutlet weak var hudView: CharacterHUDView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var hudBottomConstraint: NSLayoutConstraint!
    var sequenceToLoad: [AnimationSequenceData] = []
    internal var currentAnimationIndex = 0
    internal var sliderValue: Float = 0.5
    internal var instructionService: InstructionService?
    internal var virtualObjects: [VirtualObject] = []
    internal var currentPlacementState: ARObjectPlacementState = .ScanningEmpty
    internal weak var relatedAnimationsView: RelatedAnimationsView?
    internal var hasSetupLights = false
    
    // physics
    internal var ball: SCNNode?
    
    // MARK: - Main Setup & View Controller methods
    override func viewDidLoad() {
        super.viewDidLoad()

        Setting.registerDefaults()
        setupScene()
        setupDebug()
        setupUIControls()
		setupFocusSquare()
		updateSettings()
		resetVirtualObject()
        updatePlacementUI()
        hudDidTapShowToggle(shouldShow: false)
        
        if let hudView = hudView.view as? CharacterHUDView {
            hudView.delegate = self
        }
        
        instructionService = InstructionService(delegate: self)
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
		
		// Start the ARSession.
		restartPlaneDetection()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		session.pause()
	}
    
    // MARK: - Ball
    
    internal func setupBall(position: SCNVector3) {
        removeBall()
        
        let ballGeom = SCNSphere(radius:1.0)
        let ballMaterial = SCNMaterial()
        ballMaterial.diffuse.contents = UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0)
        ballMaterial.specular.contents = UIColor.black
        ballGeom.firstMaterial = ballMaterial
        ball = SCNNode(geometry:ballGeom)
        
        ball!.physicsBody = SCNPhysicsBody.dynamic()
        ball!.physicsBody?.mass = 0.5
        ball!.physicsBody?.restitution = 0.4
        
        ball!.physicsBody?.velocity = SCNVector3Zero
        ball!.position = position

        sceneView.scene.rootNode.addChildNode(ball!)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.removeBall()
        })
    }
    
    internal func removeBall() {
        ball?.removeFromParentNode()
    }
    
    // MARK: - Placing Object
    
    internal func updatePlacementUI() {
        if !currentPlacementState.isPlaced() {
            planes.forEach({ anchor, plane in
                if plane.anchor.extent.x > 0.3 && plane.anchor.extent.z > 0.3 {
                    self.currentPlacementState = .ScanningReady
                }
            })
        }
        
        statusLabel.text = DataLoader.sharedInstance.textForPlacementState(currentPlacementState)
        statusLabel.isHidden = currentPlacementState.hideStatusLabel()
        addObjectButton.isHidden = currentPlacementState.hideAddButton()
        hudView.isHidden = !currentPlacementState.isPlaced()
        let shouldShowDebugVisuals = currentPlacementState.showDebugVisuals()
        if showDebugVisuals != shouldShowDebugVisuals {
            showDebugVisuals = shouldShowDebugVisuals
        }
    }
    
    internal func startCharacterAnimations() {
        guard let object = virtualObjects.first else {
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
                object.loadAnimationSequence(animationSequence: self.sequenceToLoad)
                if let uke = uke {
                    self.setVirtualObject(object: uke, at: object.position)
                    uke.scale = object.scale
                    uke.eulerAngles.y = object.eulerAngles.y
                }
                
                self.virtualObjects.filter({ $0 is Uke }).forEach({ object in
                    object.loadAnimationSequence(animationSequence: self.sequenceToLoad)
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
	var sessionConfig: ARSessionConfiguration = ARWorldTrackingSessionConfiguration()
	var use3DOFTracking = false {
		didSet {
			if use3DOFTracking {
				sessionConfig = ARSessionConfiguration()
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
		refreshFeaturePoints()
		
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
		
		displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
	}
	
	func sessionWasInterrupted(_ session: ARSession) {
        instructionService?.stop()
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
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touches began")
        for object in virtualObjects {
            if currentGesture == nil {
                print("start gesture")
                currentGesture = Gesture.startGestureFromTouches(touches, self.sceneView, object, currentPlacementState)
            } else {
                print("update gesture")
                currentGesture = currentGesture!.updateGestureFromTouches(touches, .touchBegan)
            }
        }
        
		displayVirtualObjectTransform()
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		if virtualObjects.count == 0 {
			return
		}
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchMoved)
		displayVirtualObjectTransform()
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		if virtualObjects.count == 0 && currentPlacementState.isPlacingAllowed() {
			chooseObject(addObjectButton)
			return
		}
		
		currentGesture = currentGesture?.updateGestureFromTouches(touches, .touchEnded)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        let planeNode = SCNNode(geometry: planeGeo)
        planeNode.rotation = SCNVector4Make(1, 0, 0, -Float(Double.pi / 2));
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.white
        planeMaterial.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        planeGeo.materials = [planeMaterial]
        planeNode.position = target.position
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
    func setVirtualObject(object: VirtualObject, at pos: SCNVector3) {
        object.position = pos
        
        // temp for ball
        setupBall(position: SCNVector3(pos.x, pos.y + 5, pos.z))
        
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
				self.settingsButton.isEnabled = !self.isLoadingObject
				self.addObjectButton.isEnabled = !self.isLoadingObject
				self.screenshotButton.isEnabled = !self.isLoadingObject
				self.restartExperienceButton.isEnabled = !self.isLoadingObject
			}
		}
	}
	
	@IBOutlet weak var addObjectButton: UIButton!
	
	func loadVirtualObject(at index: Int) {
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
			let object = VirtualObject.availableObjects[index]
			object.viewController = self
            object.delegate = self
            object.renderingOrder = 300
            
            object.enumerateChildNodes({ node, stop in
                print(node)
                node.renderingOrder = 300
                node.geometry?.firstMaterial?.readsFromDepthBuffer = true
            })
            
			object.loadModel()
            self.virtualObjects.append(object)
            
            DispatchQueue.main.async {
                // Immediately place the object in 3D space.
				if let lastFocusSquarePos = self.focusSquare?.lastPosition {
					self.setNewVirtualObjectPosition(lastFocusSquarePos)
				} else {
					self.setNewVirtualObjectPosition(SCNVector3Zero)
				}
				
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
        
        StatManager.sharedIntance.onPlay()
    }
	
	@IBAction func chooseObject(_ button: UIButton) {
		// Abort if we are about to load another object to avoid concurrent modifications of the scene.
		if isLoadingObject { return }
		
		textManager.cancelScheduledMessage(forType: .contentPlacement)
		
        if !currentPlacementState.isPlaced() {
            loadVirtualObject(at: 0)
            currentPlacementState = .PlacedScaling
        } else if currentPlacementState == .PlacedMoving {
            startCharacterAnimations()
            currentPlacementState = .PlacedReady
            if let virtualObject = virtualObjects.first {
                // testing portal
                addPortal(position: virtualObject.position)
            }
        } else if currentPlacementState == .PlacedRotating {
            currentPlacementState = .PlacedMoving
        } else if currentPlacementState == .PlacedScaling {
            currentPlacementState = .PlacedMoving   // scaling is rotating as well now
        }
        updatePlacementUI()
    }
	
	// MARK: - VirtualObjectSelectionViewControllerDelegate
	
	func virtualObjectSelectionViewController(_: VirtualObjectSelectionViewController, didSelectObjectAt index: Int) {
		loadVirtualObject(at: index)
	}
	
	func virtualObjectSelectionViewControllerDidDeselectObject(_: VirtualObjectSelectionViewController) {
		resetVirtualObject()
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
		if let worldSessionConfig = sessionConfig as? ARWorldTrackingSessionConfiguration {
			worldSessionConfig.planeDetection = .horizontal
			session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
		}
		
		// reset timer
		if trackingFallbackTimer != nil {
			trackingFallbackTimer!.invalidate()
			trackingFallbackTimer = nil
		}
		
		textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
		                            inSeconds: 7.5,
		                            messageType: .planeEstimation)
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
		
		if virtualObjects.count > 0 && sceneView.isNode(virtualObjects.first!, insideFrustumOf: sceneView.pointOfView!) {
			focusSquare?.hide()
		} else {
			focusSquare?.unhide()
		}
		let (worldPos, planeAnchor, _) = worldPositionFromScreenPosition(screenCenter, objectPos: focusSquare?.position)
		if let worldPos = worldPos {
			focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
			textManager.cancelScheduledMessage(forType: .focusSquare)
		}
	}
    
    // MARK: - Portal
    
    func addPortal(position: SCNVector3) {
        let portal = PortalRoomObject()
        portal.position = SCNVector3(position.x, position.y - Float(Nodes.WALL_WIDTH / 2), position.z)
        sceneView.scene.rootNode.addChildNode(portal)
        
//        let wallNode = SCNNode()
//        wallNode.position = position
//
//        let sideLength = Nodes.WALL_LENGTH * 3
//        let halfSideLength = sideLength * 0.5
//
//        let endWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
//                                                       maskXUpperSide: true)
//        endWallSegmentNode.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
//        endWallSegmentNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT * 0.5), Float(Nodes.WALL_LENGTH) * -1.5)
//        wallNode.addChildNode(endWallSegmentNode)
//
//        let sideAWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
//                                                         maskXUpperSide: true)
//        sideAWallSegmentNode.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
//        sideAWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * -1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
//        wallNode.addChildNode(sideAWallSegmentNode)
//
//        let sideBWallSegmentNode = Nodes.wallSegmentNode(length: sideLength,
//                                                         maskXUpperSide: true)
//        sideBWallSegmentNode.position = SCNVector3(Float(Nodes.WALL_LENGTH) * 1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
//        wallNode.addChildNode(sideBWallSegmentNode)
//
//        let doorSideLength = (sideLength - Nodes.DOOR_WIDTH) * 0.5
//
//        let leftDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
//                                                     maskXUpperSide: true)
//        leftDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
//        leftDoorSideNode.position = SCNVector3(Float(-halfSideLength + 0.5 * doorSideLength),
//                                               Float(Nodes.WALL_HEIGHT) * Float(0.5),
//                                               Float(Nodes.WALL_LENGTH) * 1.5)
//        wallNode.addChildNode(leftDoorSideNode)
//
//        let rightDoorSideNode = Nodes.wallSegmentNode(length: doorSideLength,
//                                                      maskXUpperSide: true)
//        rightDoorSideNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
//        rightDoorSideNode.position = SCNVector3(Float(halfSideLength - 0.5 * doorSideLength),
//                                                Float(Nodes.WALL_HEIGHT) * Float(0.5),
//                                                Float(Nodes.WALL_LENGTH) * 1.5)
//        wallNode.addChildNode(rightDoorSideNode)
//
//        let aboveDoorNode = Nodes.wallSegmentNode(length: Nodes.DOOR_WIDTH,
//                                                  height: Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT)
//        aboveDoorNode.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
//        aboveDoorNode.position = SCNVector3(0,
//                                            Float(Nodes.WALL_HEIGHT) - Float(Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT) * 0.5,
//                                            Float(Nodes.WALL_LENGTH) * 1.5)
//        wallNode.addChildNode(aboveDoorNode)
//
//        let floorNode = Nodes.plane(pieces: 3,
//                                    maskYUpperSide: false)
//        floorNode.position = SCNVector3(0, 0, 0)
//        wallNode.addChildNode(floorNode)
//
//        let roofNode = Nodes.plane(pieces: 3,
//                                   maskYUpperSide: true)
//        roofNode.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT), 0)
//        wallNode.addChildNode(roofNode)
//
//        sceneView.scene.rootNode.addChildNode(wallNode)
//
//
//        // we would like shadows from inside the portal room to shine onto the floor of the camera image(!)
//        let floor = SCNFloor()
//        floor.reflectivity = 0
//        floor.firstMaterial?.diffuse.contents = UIColor.white
//        floor.firstMaterial?.colorBufferWriteMask = SCNColorMask(rawValue: 0)
//        let floorShadowNode = SCNNode(geometry:floor)
//        floorShadowNode.position = position
//        sceneView.scene.rootNode.addChildNode(floorShadowNode)
//
//
//        let light = SCNLight()
//        // [SceneKit] Error: shadows are only supported by spot lights and directional lights
//        light.type = .spot
//        light.spotInnerAngle = 70
//        light.spotOuterAngle = 120
//        light.zNear = 0.00001
//        light.zFar = 5
//        light.castsShadow = true
//        light.shadowRadius = 200
//        light.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
//        light.shadowMode = .deferred
//        let constraint = SCNLookAtConstraint(target: floorShadowNode)
//        constraint.isGimbalLockEnabled = true
//        let lightNode = SCNNode()
//        lightNode.light = light
//        lightNode.position = SCNVector3(position.x,
//                                        position.y + Float(Nodes.DOOR_HEIGHT),
//                                        position.z - Float(Nodes.WALL_LENGTH))
//        lightNode.constraints = [constraint]
//        sceneView.scene.rootNode.addChildNode(lightNode)
//
//        let node = SCNNode()
//        let object = VirtualObject.availableObjects[0]
//        object.viewController = self
//        object.delegate = self
//        object.loadModel()
//        object.renderingOrder = 200
//        object.position = SCNVector3(0, 0,  Float(Nodes.WALL_LENGTH) * 1.5)
//        node.addChildNode(object)
//
//
//        let endWallSegmentNodeMask = Nodes.wallSegmentNodeMask(length: sideLength,
//                                                       maskXUpperSide: true)
//        endWallSegmentNodeMask.eulerAngles = SCNVector3(0, 90.0.degreesToRadians, 0)
//        endWallSegmentNodeMask.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT * 0.5), Float(Nodes.WALL_LENGTH) * -1.5)
//        node.addChildNode(endWallSegmentNodeMask)
//
//        let sideAWallSegmentNodeMask = Nodes.wallSegmentNodeMask(length: sideLength,
//                                                         maskXUpperSide: true)
//        sideAWallSegmentNodeMask.eulerAngles = SCNVector3(0, 180.0.degreesToRadians, 0)
//        sideAWallSegmentNodeMask.position = SCNVector3(Float(Nodes.WALL_LENGTH) * -1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
//        node.addChildNode(sideAWallSegmentNodeMask)
//
//        let sideBWallSegmentNodeMask = Nodes.wallSegmentNodeMask(length: sideLength,
//                                                         maskXUpperSide: true)
//        sideBWallSegmentNodeMask.position = SCNVector3(Float(Nodes.WALL_LENGTH) * 1.5, Float(Nodes.WALL_HEIGHT * 0.5), 0)
//        node.addChildNode(sideBWallSegmentNodeMask)
//
//        let leftDoorSideNodeMask = Nodes.wallSegmentNodeMask(length: doorSideLength,
//                                                     maskXUpperSide: true)
//        leftDoorSideNodeMask.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
//        leftDoorSideNodeMask.position = SCNVector3(Float(-halfSideLength + 0.5 * doorSideLength),
//                                               Float(Nodes.WALL_HEIGHT) * Float(0.5),
//                                               Float(Nodes.WALL_LENGTH) * 1.5)
//        node.addChildNode(leftDoorSideNodeMask)
//
//        let rightDoorSideNodeMask = Nodes.wallSegmentNodeMask(length: doorSideLength,
//                                                      maskXUpperSide: true)
//        rightDoorSideNodeMask.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
//        rightDoorSideNodeMask.position = SCNVector3(Float(halfSideLength - 0.5 * doorSideLength),
//                                                Float(Nodes.WALL_HEIGHT) * Float(0.5),
//                                                Float(Nodes.WALL_LENGTH) * 1.5)
//        node.addChildNode(rightDoorSideNodeMask)
//
//        let aboveDoorNodeMask = Nodes.wallSegmentNodeMask(length: Nodes.DOOR_WIDTH,
//                                                  height: Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT)
//        aboveDoorNodeMask.eulerAngles = SCNVector3(0, 270.0.degreesToRadians, 0)
//        aboveDoorNodeMask.position = SCNVector3(0,
//                                            Float(Nodes.WALL_HEIGHT) - Float(Nodes.WALL_HEIGHT - Nodes.DOOR_HEIGHT) * 0.5,
//                                            Float(Nodes.WALL_LENGTH) * 1.5)
//        node.addChildNode(aboveDoorNodeMask)
//
//        let floorNodeMask = Nodes.planeMask(pieces: 3,
//                                    maskYUpperSide: false)
//        floorNodeMask.position = SCNVector3(0, 0, 0)
//        node.addChildNode(floorNodeMask)
//
//        let roofNodeMask = Nodes.planeMask(pieces: 3,
//                                   maskYUpperSide: true)
//        roofNodeMask.position = SCNVector3(0, Float(Nodes.WALL_HEIGHT), 0)
//        node.addChildNode(roofNodeMask)
//
//        node.position = SCNVector3(0, 0, 0)
//        sceneView.scene.rootNode.addChildNode(node)
    
//    will it work now that we changed the render order and position?
    
    
    
    
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
			self.featurePointCountLabel.text = "Features: \(cloud.count)".uppercased()
		}
	}
	
    var showDebugVisuals: Bool = UserDefaults.standard.bool(for: .debugMode) {
        didSet {
			featurePointCountLabel.isHidden = !showDebugVisuals
			debugMessageLabel.isHidden = !showDebugVisuals
			messagePanel.isHidden = !showDebugVisuals
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

extension ARTechniqueViewController: CharacterHUDViewDelegate {
    func hudDidUpdateSlider(value: Float) {
        sliderValue = value
        for object in virtualObjects {
            object.updateAnimationSpeed(speed: Double(value * 2))
        }
    }
    
    func hudDidTapRewind() {
        for object in virtualObjects {
            object.rewind()
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
        print("instruction: \(instruction.text)")
        instructionView.addInstruction(text: instruction.text)
    }
}

extension ARTechniqueViewController: VirtualObjectDelegate {
    func virtualObjectDidFinishAnimation(_ object: VirtualObject) {
        print("finished with sequence \(object.animationSequence)")
        instructionService?.stop()
        if let last = object.animationSequence.last {
            if let data = DataLoader.sharedInstance.characterAnimation(name: last.instructorAnimation) {
                let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
                let relatedView = RelatedAnimationsView(frame: frame)
                relatedView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
                relatedView.relatedAnimations = data.relatedAnimations ?? []
                relatedView.set(delegate: self)
                view.addSubview(relatedView)
                relatedView.animateIn()
                relatedAnimationsView = relatedView
            }
        }
    }
}

extension ARTechniqueViewController: RelatedAnimationsViewDelegate {
    func didTapRelatedAnimation(relatedView: RelatedAnimationsView, animation: String) {
        relatedAnimationsView?.animateOut()
        if let data = DataLoader.sharedInstance.characterAnimation(name: animation) {
            let animation0 = AnimationSequenceData(instructorAnimation: data.instructorAnimation, ukeAnimation: data.ukeAnimation, delay: 0, speed: 1, repeatCount: 0)
            sequenceToLoad = [animation0]
            startCharacterAnimations()
        }
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
