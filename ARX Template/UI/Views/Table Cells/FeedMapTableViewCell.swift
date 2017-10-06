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

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var heatImageView: UIImageView!
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var motivationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mapView.delegate = self
        
        backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.labelTitleColor()
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        titleLabel.text = "Breath of Fire Community"
        motivationLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        motivationLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        
        FirebaseService.sharedInstance.retrieveMotivationOfTheDay() { [unowned self] quote in
            // was the bird quote 9/3
            self.motivationLabel.text = quote
        }
    }

    func update(locations: [CLLocation]) {
        let span = MKCoordinateSpanMake(25.502001722875953, 67.978134479121621)
        var center = CLLocationCoordinate2DMake(38.836910245556396, -95.823448005444746)
        if let user = SessionManager.sharedInstance.currentUserData,
            let userCoordinate = user.coordinate {
            center = userCoordinate
        }
        mapView.region = MKCoordinateRegionMake(center, span)
        
        
        let weights = locations.map({ _ in
            return Double(1)
        })
        let heatMap = LFHeatMap.heatMap(for: mapView, boost: 1, locations: locations, weights: weights)
        heatImageView.image = heatMap
    }
}

extension FeedMapTableViewCell: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print(mapView.center)
        print(mapView.region)
    }
}
