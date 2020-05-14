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
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save to CoreData: \(error)")
            }
        }
    }
    
    func cleanUp(){
        saveContext()
    }
    
    func resetChildContext(){
        childContext.reset()
    }
    
    func saveChildContext(){
        if childContext.hasChanges {
            do {
                try childContext.save()
            } catch {
                fatalError("Failed to save child context: \(error)")
            }
        }
    }
    
    func createChildCountryCopy(id: NSObject) -> Country {
        let countryCopy = childContext.object(with: id as! NSManagedObjectID)
        return countryCopy as! Country
    }
    
    func createCountry(name: String, currencyAbbreviation: String) -> Country {
        let country = NSEntityDescription.insertNewObject(forEntityName: "Country", into: childContext) as! Country
        country.name = name
        country.currencyAbbreviation = currencyAbbreviation
        return country
    }
    
    func createCurrency() -> Currency {
        let currency = NSEntityDescription.insertNewObject(forEntityName: "Currency", into: childContext) as! Currency
        return currency
    }
    
    func addCurrency(country: Country, currency: Currency) {
        if let old_currency = country.currency {
            country.currency = currency
            childContext.delete(old_currency)
        }
    }

    func removeCountry(country: Country) {
        persistentContainer.viewContext.delete(country)
    }
    
    func removeCurrency(currency: Currency) {
        persistentContainer.viewContext.delete(currency)
    }
    
    /*
     This function is called when a listener is updated, and will do appropriate action.
     */
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == .country {
            listener.onCountryChange(change: .update, countries: fetchAllCountries())
        }
    }
    
    /*
     This function removes a listener.
     */
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    /*
     Fetching starts here
     */
    
    /*
     This function fetches a list of cocktails from the coredata and returns it.
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
    
    // NSFetchedResultsController delegate
    /*
     If the controller changed context, do appropriate action by calling responsible methods.
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == countryFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .country {
                    listener.onCountryChange(change: .update, countries: fetchAllCountries())
                }
            }
        }
    }
}
