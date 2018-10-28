/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for app settings.
*/

import UIKit

enum Setting: String {
    // Bool settings with SettingsViewController switches
    case debugMode
    case scaleWithPinchGesture
    case ambientLightEstimation
    case dragOnInfinitePlanes
    case showHitTestAPI
    case use3DOFTracking
    case use3DOFFallback
	case useOcclusionPlanes
    
    case playCount
    case playCountToday
    case lastPlay
    case intention
    case arMode
    case durationSliderValue
    case tutorialFlag

    // Integer state used in virtual object picker
    case selectedObjectID

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Setting.ambientLightEstimation.rawValue: true,
            Setting.dragOnInfinitePlanes.rawValue: true,
            Setting.selectedObjectID.rawValue: -1
        ])
    }
}
extension UserDefaults {
    func bool(for setting: Setting, defaultValue: Bool? = nil) -> Bool {
        if let defaultValue = defaultValue,
            object(forKey: setting.rawValue) == nil {
            return defaultValue
        }
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
    func integer(for setting: Setting) -> Int {
        return integer(forKey: setting.rawValue)
    }
    func set(_ integer: Int, for setting: Setting) {
        set(integer, forKey: setting.rawValue)
    }
    func double(for setting: Setting) -> Double {
        return double(forKey: setting.rawValue)
    }
    func set(_ double: Double, for setting: Setting) {
        set(double, forKey: setting.rawValue)
    }
    func float(for setting: Setting) -> Float {
        return float(forKey: setting.rawValue)
    }
    func set(_ float: Float, for setting: Setting) {
        set(float, forKey: setting.rawValue)
    }
    func date(for setting: Setting) -> Date? {
        return object(forKey: setting.rawValue) as? Date
    }
    func set(_ date: Date, for setting: Setting) {
        set(date, forKey: setting.rawValue)
    }
    func string(for setting: Setting) -> String? {
        return object(forKey: setting.rawValue) as? String
    }
    func set(_ string: String, for setting: Setting) {
        set(string, forKey: setting.rawValue)
    }
}

class SettingsViewController: UITableViewController {
	
	@IBOutlet weak var debugModeSwitch: UISwitch!
	@IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
	@IBOutlet weak var ambientLightEstimateSwitch: UISwitch!
	@IBOutlet weak var dragOnInfinitePlanesSwitch: UISwitch!
	@IBOutlet weak var showHitTestAPISwitch: UISwitch!
	@IBOutlet weak var use3DOFTrackingSwitch: UISwitch!
	@IBOutlet weak var useAuto3DOFFallbackSwitch: UISwitch!
	@IBOutlet weak var useOcclusionPlanesSwitch: UISwitch!
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        populateSettings()
    }

	@IBAction func didChangeSetting(_ sender: UISwitch) {
		let defaults = UserDefaults.standard
		switch sender {
            case debugModeSwitch:
                defaults.set(sender.isOn, for: .debugMode)
            case scaleWithPinchGestureSwitch:
                defaults.set(sender.isOn, for: .scaleWithPinchGesture)
            case ambientLightEstimateSwitch:
                defaults.set(sender.isOn, for: .ambientLightEstimation)
            case dragOnInfinitePlanesSwitch:
                defaults.set(sender.isOn, for: .dragOnInfinitePlanes)
            case showHitTestAPISwitch:
                defaults.set(sender.isOn, for: .showHitTestAPI)
            case use3DOFTrackingSwitch:
                defaults.set(sender.isOn, for: .use3DOFTracking)
            case useAuto3DOFFallbackSwitch:
                defaults.set(sender.isOn, for: .use3DOFFallback)
			case useOcclusionPlanesSwitch:
				defaults.set(sender.isOn, for: .useOcclusionPlanes)
            default: break
		}
	}
	
	private func populateSettings() {
		let defaults = UserDefaults.standard

		debugModeSwitch.isOn = defaults.bool(for: Setting.debugMode)
		scaleWithPinchGestureSwitch.isOn = defaults.bool(for: .scaleWithPinchGesture)
		ambientLightEstimateSwitch.isOn = defaults.bool(for: .ambientLightEstimation)
		dragOnInfinitePlanesSwitch.isOn = defaults.bool(for: .dragOnInfinitePlanes)
		showHitTestAPISwitch.isOn = defaults.bool(for: .showHitTestAPI)
		use3DOFTrackingSwitch.isOn = defaults.bool(for: .use3DOFTracking)
		useAuto3DOFFallbackSwitch.isOn = defaults.bool(for: .use3DOFFallback)
		useOcclusionPlanesSwitch.isOn = defaults.bool(for: .useOcclusionPlanes)
	}
}
