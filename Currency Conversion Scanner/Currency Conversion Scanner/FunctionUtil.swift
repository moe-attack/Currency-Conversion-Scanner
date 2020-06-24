//
//  FunctionUtil.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 19/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import UIKit

/*
 This function adds shadow to the view. This function will be allowed to be called globally.
 view: The view to add shadows on.
 */
public func addShadowsToView(view: UIView) {
    view.layer.masksToBounds = false
    view.layer.shadowColor = UIColor.lightGray.cgColor
    view.layer.shadowOpacity = 0.8
    view.layer.shadowOffset = CGSize(width: 0, height: 2.0)
    view.layer.shadowRadius = 2
}
