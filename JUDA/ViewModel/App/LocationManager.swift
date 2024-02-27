//
//  LocationManager.swift
//  JUDA
//
//  Created by 백대홍 on 2/27/24.
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    private let locationManager = CLLocationManager()
    var location: CLLocation?
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
}
