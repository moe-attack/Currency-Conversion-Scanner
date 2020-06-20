//
//  WebServiceManager.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 18/6/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation

class WebServiceManager {
    
    func getRateFromCurrency(currency: Currency?, abbre: String) -> Double {
        var retRate = 0.0
        switch abbre{
        case "CAD":
            if let rate = currency?.cad {
                retRate = rate
            }
        case "HKD":
            if let rate = currency?.hkd {
                retRate = rate
            }
        case "ISK":
            if let rate = currency?.isk {
                retRate = rate
            }
        case "PHP":
            if let rate = currency?.php {
                retRate = rate
            }
        case "DKK":
            if let rate = currency?.dkk {
                retRate = rate
            }
        case "HUF":
            if let rate = currency?.huf {
                retRate = rate
            }
        case "CZK":
            if let rate = currency?.czk {
                retRate = rate
            }
        case "GBP":
            if let rate = currency?.gbp {
                retRate = rate
            }
        case "RON":
            if let rate = currency?.ron {
                retRate = rate
            }
        case "SEK":
            if let rate = currency?.sek {
                retRate = rate
            }
        case "IDR":
            if let rate = currency?.idr {
                retRate = rate
            }
        case "INR":
            if let rate = currency?.inr {
                retRate = rate
            }
        case "BRL":
            if let rate = currency?.brl {
                retRate = rate
            }
        case "RUB":
            if let rate = currency?.rub {
                retRate = rate
            }
        case "HRK":
            if let rate = currency?.hrk {
                retRate = rate
            }
        case "JPY":
            if let rate = currency?.jpy {
                retRate = rate
            }
        case "THB":
            if let rate = currency?.thb {
                retRate = rate
            }
        case "CHF":
            if let rate = currency?.chf {
                retRate = rate
            }
        case "EUR":
            if let rate = currency?.eur {
                retRate = rate
            }
        case "MYR":
            if let rate = currency?.myr {
                retRate = rate
            }
        case "BGN":
            if let rate = currency?.bgn {
                retRate = rate
            }
        case "TRY":
            if let rate = currency?.try0 {
                retRate = rate
            }
        case "CNY":
            if let rate = currency?.cny {
                retRate = rate
            }
        case "NOK":
            if let rate = currency?.nok {
                retRate = rate
            }
        case "NZD":
            if let rate = currency?.nzd {
                retRate = rate
            }
        case "ZAR":
            if let rate = currency?.zar {
                retRate = rate
            }
        case "USD":
            if let rate = currency?.usd {
                retRate = rate
            }
        case "MXN":
            if let rate = currency?.mxn {
                retRate = rate
            }
        case "SGD":
            if let rate = currency?.sgd {
                retRate = rate
            }
        case "AUD":
            if let rate = currency?.aud {
                retRate = rate
            }
        case "ILS":
            if let rate = currency?.ils {
                retRate = rate
            }
        case "KRW":
            if let rate = currency?.krw {
                retRate = rate
            }
        case "PLN":
            if let rate = currency?.pln {
                retRate = rate
            }
        default:
            ()
        }
        
        return retRate
    }
    
    func getRateFromCurrencyData(currency: CurrencyData?, abbre: String) -> Double {
        var retRate = 0.0
        switch abbre{
        case "CAD":
            if let rate = currency?.cad {
                retRate = rate
            }
        case "HKD":
            if let rate = currency?.hkd {
                retRate = rate
            }
        case "ISK":
            if let rate = currency?.isk {
                retRate = rate
            }
        case "PHP":
            if let rate = currency?.php {
                retRate = rate
            }
        case "DKK":
            if let rate = currency?.dkk {
                retRate = rate
            }
        case "HUF":
            if let rate = currency?.huf {
                retRate = rate
            }
        case "CZK":
            if let rate = currency?.czk {
                retRate = rate
            }
        case "GBP":
            if let rate = currency?.gbp {
                retRate = rate
            }
        case "RON":
            if let rate = currency?.ron {
                retRate = rate
            }
        case "SEK":
            if let rate = currency?.sek {
                retRate = rate
            }
        case "IDR":
            if let rate = currency?.idr {
                retRate = rate
            }
        case "INR":
            if let rate = currency?.inr {
                retRate = rate
            }
        case "BRL":
            if let rate = currency?.brl {
                retRate = rate
            }
        case "RUB":
            if let rate = currency?.rub {
                retRate = rate
            }
        case "HRK":
            if let rate = currency?.hrk {
                retRate = rate
            }
        case "JPY":
            if let rate = currency?.jpy {
                retRate = rate
            }
        case "THB":
            if let rate = currency?.thb {
                retRate = rate
            }
        case "CHF":
            if let rate = currency?.chf {
                retRate = rate
            }
        case "EUR":
            if let rate = currency?.eur {
                retRate = rate
            }
        case "MYR":
            if let rate = currency?.myr {
                retRate = rate
            }
        case "BGN":
            if let rate = currency?.bgn {
                retRate = rate
            }
        case "TRY":
            if let rate = currency?.try0 {
                retRate = rate
            }
        case "CNY":
            if let rate = currency?.cny {
                retRate = rate
            }
        case "NOK":
            if let rate = currency?.nok {
                retRate = rate
            }
        case "NZD":
            if let rate = currency?.nzd {
                retRate = rate
            }
        case "ZAR":
            if let rate = currency?.zar {
                retRate = rate
            }
        case "USD":
            if let rate = currency?.usd {
                retRate = rate
            }
        case "MXN":
            if let rate = currency?.mxn {
                retRate = rate
            }
        case "SGD":
            if let rate = currency?.sgd {
                retRate = rate
            }
        case "AUD":
            if let rate = currency?.aud {
                retRate = rate
            }
        case "ILS":
            if let rate = currency?.ils {
                retRate = rate
            }
        case "KRW":
            if let rate = currency?.krw {
                retRate = rate
            }
        case "PLN":
            if let rate = currency?.pln {
                retRate = rate
            }
        default:
            ()
        }
        
        return retRate
    }

}
