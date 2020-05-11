//
//  Currency+CoreDataProperties.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 9/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//
//

import Foundation
import CoreData


extension Currency {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Currency> {
        return NSFetchRequest<Currency>(entityName: "Currency")
    }

    @NSManaged public var aud: Double
    @NSManaged public var bgn: Double
    @NSManaged public var brl: Double
    @NSManaged public var cad: Double
    @NSManaged public var chf: Double
    @NSManaged public var cny: Double
    @NSManaged public var czk: Double
    @NSManaged public var dkk: Double
    @NSManaged public var eur: Double
    @NSManaged public var gbp: Double
    @NSManaged public var hkd: Double
    @NSManaged public var hrk: Double
    @NSManaged public var huf: Double
    @NSManaged public var idr: Double
    @NSManaged public var ils: Double
    @NSManaged public var inr: Double
    @NSManaged public var isk: Double
    @NSManaged public var jpy: Double
    @NSManaged public var krw: Double
    @NSManaged public var mxn: Double
    @NSManaged public var myr: Double
    @NSManaged public var nok: Double
    @NSManaged public var nzd: Double
    @NSManaged public var php: Double
    @NSManaged public var pln: Double
    @NSManaged public var ron: Double
    @NSManaged public var rub: Double
    @NSManaged public var sek: Double
    @NSManaged public var sgd: Double
    @NSManaged public var thb: Double
    @NSManaged public var try0: Double
    @NSManaged public var usd: Double
    @NSManaged public var zar: Double
    @NSManaged public var country: Country?

}
