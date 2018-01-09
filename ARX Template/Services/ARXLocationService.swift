//
//  ARXLocationService.swift
//  ARX Template
//
//  Created by Daniel Ho on 10/28/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation

typealias LocationHandler = (CLLocationCoordinate2D?)->Void

class ARXLocationService: NSObject {
    static let sharedInstance = ARXLocationService()
    
    internal let locationManager = CLLocationManager()
    internal var locationHandler: LocationHandler?
    internal var userData: UserData?
    
    func retrieveUserLocation(userData: UserData?, handler: @escaping LocationHandler) {
        self.userData = userData
        self.locationHandler = handler
        
        locationManager.delegate = self

        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .denied || authStatus == .restricted {
            executeLocationHandler(userData?.coordinate)
            return
        } else if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            attemptRetrieveLocation()
        }
    }
    
    fileprivate func attemptRetrieveLocation() {
        locationManager.startUpdatingLocation()
    }
    
    fileprivate func executeLocationHandler(_ coordinate: CLLocationCoordinate2D?) {
        locationHandler?(coordinate)
        locationHandler = nil
    }
    
    /* Standardises and angle to [-180 to 180] degrees */
    class func standardAngle(_ inputAngle: CLLocationDegrees) -> CLLocationDegrees {
        let angle = inputAngle.truncatingRemainder(dividingBy: 360)
        return angle < -180 ? -360 - angle : angle > 180 ? 360 - 180 : angle
    }
    
    /* confirms that a region contains a location */
    class func regionContains(region: MKCoordinateRegion, coordinate: CLLocationCoordinate2D) -> Bool {
        let deltaLat = abs(standardAngle(region.center.latitude - coordinate.latitude))
        let deltalong = abs(standardAngle(region.center.longitude - coordinate.longitude))
        return region.span.latitudeDelta >= deltaLat && region.span.longitudeDelta >= deltalong
    }
}

extension ARXLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            executeLocationHandler(location.coordinate)
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            executeLocationHandler(userData?.coordinate)
        } else {
            attemptRetrieveLocation()
        }
    }
}
