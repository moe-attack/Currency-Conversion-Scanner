//
//  RawCurrencyData.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 9/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation

class RawCurrencyData: NSObject, Decodable {
    
    var rates: CurrencyData?
    
    // This is the coding key to decode a JSON object
    private enum CodingKeys: String, CodingKey {
        case rates
    }
}
