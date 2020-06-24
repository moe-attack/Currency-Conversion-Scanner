//
//  AppDelegate.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 4/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var databaseController: DatabaseProtocol?
    var locationManager = LocationManager()
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        databaseController?.cleanUp()
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // The database controller instance will be shared across the app
        databaseController = CoreDataController()
        // The app will get user's location on start
        if let exposeLocation = locationManager.exposedLocation {
            locationManager.getPlace(for: exposeLocation) { placeMark in
                guard let placeMark = placeMark else {return}
                UserDefaults.standard.set(placeMark.country, forKey: Constants.persistentKey.currentLocation)
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

}

