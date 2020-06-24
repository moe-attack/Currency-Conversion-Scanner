//
//  SplashScreenViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 20/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import UIKit
import LTMorphingLabel

class SplashScreenViewController: UIViewController {
       
    
    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var logoText: LTMorphingLabel!
    
    /*
     This function defines what happens when a view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure the text update animation effect
        logoText.morphingEffect = .sparkle
        logoText.morphingDuration = 1
    }
    
    /*
     This function is called after viewDidLoad.
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // DispatchQueue is called here instead of viewDidLoad because in viewDidLoad, Controller hasn't been added to view hierarchy
        // Show 2 seconds of first string
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // Update the text with animation
            self.logoText.text = Constants.splashScreen.logoText
        }
        // Show 2 seconds of last string then present the main view controller
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UINavigationController = storyboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true, completion: nil)
        }
    }
}
