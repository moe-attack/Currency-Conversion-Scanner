//
//  DatabaseDelegate.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 8/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//
import Foundation

enum DatabaseOperation {
    case update
}

enum ListenerType {
    case country
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onCountryChange(change: DatabaseOperation, countries: [Country])
}

protocol DatabaseProtocol: AnyObject {
    func createCountry(name: String, currencyAbbreviation: String) -> Country
    func createCurrency() -> Currency
    func removeCountry(country: Country)
    func addCurrency(country: Country, currency: Currency)
    func removeCurrency(currency: Currency)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    func cleanUp()
    func resetChildContext()
    func saveChildContext()
    func createChildCountryCopy(id: NSObject) -> Country  // create a child cocktail copy
}
