//
//  AddCurrencyDelegate.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 11/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation

protocol AddCurrencyDelegate: NSObject{
    func addNewCurrency(country_name: String, currencyAbbreviation: String)
}
