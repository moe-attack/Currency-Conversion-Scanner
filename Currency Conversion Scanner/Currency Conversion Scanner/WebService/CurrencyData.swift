//
//  CurrencyData.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 9/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation

class CurrencyData: NSObject, Decodable {
    var cad: Double?
    var hkd: Double?
    var isk: Double?
    var php: Double?
    var dkk: Double?
    var huf: Double?
    var czk: Double?
    var gbp: Double?
    var ron: Double?
    var sek: Double?
    var idr: Double?
    var inr: Double?
    var brl: Double?
    var rub: Double?
    var hrk: Double?
    var jpy: Double?
    var thb: Double?
    var chf: Double?
    var eur: Double?
    var myr: Double?
    var bgn: Double?
    var try0: Double?
    var cny: Double?
    var nok: Double?
    var nzd: Double?
    var zar: Double?
    var usd: Double?
    var mxn: Double?
    var sgd: Double?
    var aud: Double?
    var ils: Double?
    var krw: Double?
    var pln: Double?
    
    // This is the coding key to decode a JSON object
    private enum ratesKeys: String, CodingKey {
        case cad = "CAD"
        case hkd = "HKD"
        case isk = "ISK"
        case php = "PHP"
        case dkk = "DKK"
        case huf = "HUF"
        case czk = "CZK"
        case gbp = "GBP"
        case ron = "RON"
        case sek = "SEK"
        case idr = "IDR"
        case inr = "INR"
        case brl = "BRL"
        case rub = "RUB"
        case hrk = "HRK"
        case jpy = "JPY"
        case thb = "THB"
        case chf = "CHF"
        case eur = "EUR"
        case myr = "MYR"
        case bgn = "BGN"
        case try0 = "TRY"
        case cny = "CNY"
        case nok = "NOK"
        case nzd = "NZD"
        case zar = "ZAR"
        case usd = "USD"
        case mxn = "MXN"
        case sgd = "SGD"
        case aud = "AUD"
        case ils = "ILS"
        case krw = "KRW"
        case pln = "PLN"
    }
    
    // When decode, decode each key and store the outcome in local variable
    required init(from decoder: Decoder) throws {
        let rootContainer = try decoder.container(keyedBy: ratesKeys.self)
        cad = try rootContainer.decode(Double.self, forKey: .cad)
        hkd = try rootContainer.decode(Double.self, forKey: .hkd)
        isk = try rootContainer.decode(Double.self, forKey: .isk)
        php = try rootContainer.decode(Double.self, forKey: .php)
        dkk = try rootContainer.decode(Double.self, forKey: .dkk)
        huf = try rootContainer.decode(Double.self, forKey: .huf)
        czk = try rootContainer.decode(Double.self, forKey: .czk)
        gbp = try rootContainer.decode(Double.self, forKey: .gbp)
        ron = try rootContainer.decode(Double.self, forKey: .ron)
        sek = try rootContainer.decode(Double.self, forKey: .sek)
        idr = try rootContainer.decode(Double.self, forKey: .idr)
        inr = try rootContainer.decode(Double.self, forKey: .inr)
        brl = try rootContainer.decode(Double.self, forKey: .brl)
        rub = try rootContainer.decode(Double.self, forKey: .rub)
        hrk = try rootContainer.decode(Double.self, forKey: .hrk)
        jpy = try rootContainer.decode(Double.self, forKey: .jpy)
        thb = try rootContainer.decode(Double.self, forKey: .thb)
        chf = try rootContainer.decode(Double.self, forKey: .chf)
        eur = try rootContainer.decode(Double.self, forKey: .eur)
        myr = try rootContainer.decode(Double.self, forKey: .myr)
        bgn = try rootContainer.decode(Double.self, forKey: .bgn)
        try0 = try rootContainer.decode(Double.self, forKey: .try0)
        cny = try rootContainer.decode(Double.self, forKey: .cny)
        nok = try rootContainer.decode(Double.self, forKey: .nok)
        nzd = try rootContainer.decode(Double.self, forKey: .nzd)
        zar = try rootContainer.decode(Double.self, forKey: .zar)
        usd = try rootContainer.decode(Double.self, forKey: .usd)
        mxn = try rootContainer.decode(Double.self, forKey: .mxn)
        sgd = try rootContainer.decode(Double.self, forKey: .sgd)
        aud = try rootContainer.decode(Double.self, forKey: .aud)
        ils = try rootContainer.decode(Double.self, forKey: .ils)
        krw = try rootContainer.decode(Double.self, forKey: .krw)
        pln = try rootContainer.decode(Double.self, forKey: .pln)

    }
}
