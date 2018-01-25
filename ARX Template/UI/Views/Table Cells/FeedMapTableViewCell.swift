//
//  FeedMapTableViewCell.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/21/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import CoreLocation

class FeedMapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var heatImageView: UIImageView!
    @IBOutlet weak var motivationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapView.delegate = self
        
        motivationLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        motivationLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
    }

    func update(locations: [CLLocation]) {
        
        var minLng: CLLocationDegrees?
        var maxLng: CLLocationDegrees?
        var minLat: CLLocationDegrees?
        var maxLat: CLLocationDegrees?
        locations.forEach({ location in
            if let val = minLng {
                if location.coordinate.longitude < val {
                    minLng = location.coordinate.longitude
                }
            } else {
                minLng = location.coordinate.longitude
            }
            if let val = maxLng {
                if location.coordinate.longitude > val {
                    maxLng = location.coordinate.longitude
                }
            } else {
                maxLng = location.coordinate.longitude
            }
            if let val = minLat {
                if location.coordinate.latitude < val {
                    minLat = location.coordinate.latitude
                }
            } else {
                minLat = location.coordinate.latitude
            }
            if let val = maxLat {
                if location.coordinate.latitude > val {
                    maxLat = location.coordinate.latitude
                }
            } else {
                maxLat = location.coordinate.latitude
            }
        })
        
//        let span = MKCoordinateSpanMake(25.502001722875953, 67.978134479121621) // US
//        let span = MKCoordinateSpanMake(12, 35) // State
        var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2DMake(38.836910245556396, -95.823448005444746),
                                           span: MKCoordinateSpanMake(25.502001722875953, 67.978134479121621))
        var span = MKCoordinateSpanMake(0.5, 0.5) // County
        if let minLng = minLng,
            let maxLng = maxLng,
            let minLat = minLat,
            let maxLat = maxLat {
            let spanMultiplier: Double = 1.5
            span = MKCoordinateSpanMake(spanMultiplier * (maxLat - minLat), spanMultiplier * (maxLng - minLng))
            mapRegion = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: maxLat - span.latitudeDelta / 2, longitude: maxLng - span.longitudeDelta / 2), span)
        }
        
        
        var center: CLLocationCoordinate2D?
        if let user = SessionManager.sharedInstance.currentUserData,
            let userCoordinate = user.coordinate {
            
            if ARXLocationService.regionContains(region: mapRegion, coordinate: userCoordinate) {
                center = userCoordinate
            }
        }
        if let center = center {
            mapRegion = MKCoordinateRegionMake(center, span)
        }
        mapView.region = mapRegion

        let weights = locations.map({ _ in
            return Double(0.5)
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: { [unowned self] in
            let heatMap = LFHeatMap.heatMap(for: self.mapView, boost: 1, locations: locations, weights: weights)
            self.heatImageView.image = heatMap
        })
    }
    
    func updateQuote(_ quote: String?) {
        motivationLabel.text = quote
    }
}

extension FeedMapTableViewCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(mapView.center)
        print(mapView.region)
    }
}
