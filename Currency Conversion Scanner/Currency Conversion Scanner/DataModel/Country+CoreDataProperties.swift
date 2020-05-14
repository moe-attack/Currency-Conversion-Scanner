//
//  Country+CoreDataProperties.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 8/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//
//

import Foundation
import CoreData


extension Country {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Country> {
        return NSFetchRequest<Country>(entityName: "Country")
    }

    @NSManaged public var name: String?
    @NSManaged public var currencyAbbreviation: String?
    @NSManaged public var currency: Currency?

}
