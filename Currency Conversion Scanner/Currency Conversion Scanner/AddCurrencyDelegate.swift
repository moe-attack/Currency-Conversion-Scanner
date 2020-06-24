//
//  AddCurrencyDelegate.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 11/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation

/*
 This is a protocol meant to serve as a delegate, used when we want changes from one view affects the other view.
 */
protocol AddCurrencyDelegate: NSObject{
    // The add currency view will use the delegate to pass the name of the new country and currency abbreviation back to
    // currency list
    func addNewCurrency(country_name: String, currencyAbbreviation: String)
}
