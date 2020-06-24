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
    
    /*
     This is the constructor of the class
     */
    override init() {
        super.init()
        // set up the locationManager's configuration
        locationManager.delegate = self
        // we don't need high accuracy as long as the country name can be captured
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.requestWhenInUseAuthorization()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    /*
     This function prints the location when it is updated, just for debugging usage
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
}

extension LocationManager {
    /*
     This function get the placemark using the geocoder, once user permission is granted
     */
    func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        // get the placemark which contains information of user location
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            // ensure there is no error before proceeding
            guard error == nil else {
                print("Error in getPlace: \(error!)")
                completion(nil)
                return
            }
            
            // get the first placemark in the list
            guard let placemark = placemarks?[0] else {
                print("Error in getPlace placemarks: placemark is nil.")
                completion(nil)
                return
            }
            
            completion(placemark)
        }
    }
}
