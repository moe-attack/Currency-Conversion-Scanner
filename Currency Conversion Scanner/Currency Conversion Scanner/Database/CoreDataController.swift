//
//  CoreDataController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 8/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//
import Foundation
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate{
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer
    var countryFetchedResultsController: NSFetchedResultsController<Country>?
    let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    /*
     In constructor we create the persistent container and load its data stack. we then update the child context's parent context ot this persistent container's view context
     */
    override init(){
        persistentContainer = NSPersistentContainer(name: "CountryCurrencyModel")
        persistentContainer.loadPersistentStores(){ (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data Stack: \(error)")
            }
        }
        childContext.parent = persistentContainer.viewContext
        super.init()
    }
    
    /*
     This function saves the view context to database
     */
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save to CoreData: \(error)")
            }
        }
    }
    
    /*
     This function calls the save context function
     */
    func cleanUp(){
        saveContext()
    }
    
    /*
     This function resets the child object and clear all data in it
     */
    func resetChildContext(){
        childContext.reset()
    }
    
    /*
     This function saves the child object and pushes its changes to the parent context
     */
    func saveChildContext(){
        if childContext.hasChanges {
            do {
                try childContext.save()
            } catch {
                fatalError("Failed to save child context: \(error)")
            }
        }
    }
    
    /*
     This function creates a country child object by using the parent object ID
     id: The NSManagedObjectID from the parent country object
     return: The child country object
     */
    func createChildCountryCopy(id: NSObject) -> Country {
        let countryCopy = childContext.object(with: id as! NSManagedObjectID)
        return countryCopy as! Country
    }
    
    /*
     This function creates a new country object in the database.
     name: Name of the country to be created
     currencyAbbreviation: the currency abbreviation of the country to be created
     return: the country created
     */
    func createCountry(name: String, currencyAbbreviation: String) -> Country {
        let country = NSEntityDescription.insertNewObject(forEntityName: "Country", into: childContext) as! Country
        country.name = name
        country.currencyAbbreviation = currencyAbbreviation
        return country
    }
    
    /*
     This function creates a new empty currency in the database.
     return: the currency created
     */
    func createCurrency() -> Currency {
        let currency = NSEntityDescription.insertNewObject(forEntityName: "Currency", into: childContext) as! Currency
        return currency
    }
    
    /*
     This function adds a currency to the country, to create database relationship between the two.
     country: The country to be added with a currency
     currency: The currency to add to a country
     */
    func addCurrency(country: Country, currency: Currency) {
        if let old_currency = country.currency {
            childContext.delete(old_currency)
        }
        country.currency = currency
    }

    /*
     This function removes a country from the view context.
     country: The country to be removed
     */
    func removeCountry(country: Country) {
        persistentContainer.viewContext.delete(country)
    }
    
    /*
     This function removes a currency from the view context.
     currency: The Currency to be removed
     */
    func removeCurrency(currency: Currency) {
        persistentContainer.viewContext.delete(currency)
    }
    
    /*
     This function is called when a listener is updated, and will do appropriate action.
     listener: The listener listening to the database
     */
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .country {
            listener.onCountryChange(countries: fetchAllCountries())
        }
    }
    
    /*
     This function removes a listener from the list.
     listener: The listener listening to the database
     */
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    /*
     This function fetches a list of countries from the coredata and returns it.
     return: A list of countries fetched from the database fetch result controller
     */
    func fetchAllCountries() -> [Country] {
        // if the controller has not been initalized yet
        if countryFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
            // sort the fetched result by name
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            // link the controller to the main context
            countryFetchedResultsController = NSFetchedResultsController<Country>(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            countryFetchedResultsController?.delegate = self
            
            do {
                try countryFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request Failed: \(error)")
            }
        }
        
        // fetch the object and returns it.
        var countries = [Country]()
        if countryFetchedResultsController?.fetchedObjects != nil {
            countries = (countryFetchedResultsController?.fetchedObjects)!
        }
        
        return countries
    }
    
    /*
     If the controller changed context, do appropriate action by calling responsible methods.
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == countryFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .country {
                    listener.onCountryChange(countries: fetchAllCountries())
                }
            }
        }
    }
}
