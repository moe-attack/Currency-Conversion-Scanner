//
//  LocationManager.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 27/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    private let locationManager = CLLocationManager()
    public var exposedLocation: CLLocation? { return locationManager.location }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            ()
        case .restricted:
            ()
        case .notDetermined:
            ()
        case .authorizedAlways:
            ()
        case .authorizedWhenInUse:
            ()
        @unknown default:
            fatalError("Error when checking CoreLocation authorization status")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
}

extension LocationManager {
    func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Error in getPlace: \(error!)")
                completion(nil)
                return
            }
            
            guard let placemark = placemarks?[0] else {
                print("Error in getPlace placemarks: placemark is nil.")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
}
