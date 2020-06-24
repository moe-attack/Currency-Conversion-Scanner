//
//  DatabaseDelegate.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 8/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//
import Foundation

/*
 The type of listener. Currently only have country but having a type makes code extendable (Open Close principle)
 */
enum ListenerType {
    case country
}

/*
 The protocol listed the listener type getter setter, and also the function to invoke when listener observed database changes
 */
protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onCountryChange(countries: [Country])
}

/*
 A list of protocols the database has to implement
 */
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
