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
            handler(userData?.coordinate)
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
}

extension ARXLocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationHandler?(location.coordinate)
            manager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied || status == .restricted {
            locationHandler?(userData?.coordinate)
        } else {
            attemptRetrieveLocation()
        }
    }
}
