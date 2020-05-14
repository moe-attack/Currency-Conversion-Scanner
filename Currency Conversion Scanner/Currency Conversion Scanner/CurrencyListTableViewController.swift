//
//  CurrencyListTableViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 8/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import UIKit

class CurrencyListTableViewController: UITableViewController, DatabaseListener, AddCurrencyDelegate{
   
    var listenerType: ListenerType = .country
    weak var databaseController: DatabaseProtocol?
    var currency: CurrencyData?
    
    var defaultCurrency = "AUD"
    var countries = [Country]()
    
    let CURRENCY_CELL = "CurrencyListCell"
    let ADD_CELL = "AddCurrencyCell"
    let CURRENCY_CELL_INDEX = 0
    let ADD_CELL_INDEX = 1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case CURRENCY_CELL_INDEX:
            return countries.count
        case ADD_CELL_INDEX:
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == CURRENCY_CELL_INDEX {
            let cell = tableView.dequeueReusableCell(withIdentifier: CURRENCY_CELL, for: indexPath) as! CurrencyListCell
            let country = countries[indexPath.row]
            cell.countryLabel.text = country.name?.uppercased()
            if let rate = country.currency?.sgd{
                cell.rateLabel.text = String(format: "1 %@ = %@ %@", defaultCurrency, String(roundUpDouble(number: rate)), country.currencyAbbreviation!).uppercased()
            }
            if let name = country.name {
                cell.flagIcon.image = UIImage(named: name)
            }
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: ADD_CELL, for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        case CURRENCY_CELL_INDEX:
            return String(format: "Default Currency: %@", defaultCurrency)
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == CURRENCY_CELL_INDEX{
            return true
        }
        return false
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let country = countries[indexPath.row]
        let currency = country.currency!
        if editingStyle == .delete && indexPath.section == CURRENCY_CELL_INDEX {
            databaseController?.removeCountry(country: country)
            databaseController?.removeCurrency(currency: currency)
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addCurrencySegue":
            let destination = segue.destination as! AddCurrencyViewController
            destination.addCurrencyDelegate = self
        default:
            ()
        }
    }
    
    func onCountryChange(change: DatabaseOperation, countries: [Country]) {
        self.countries = countries
        tableView.reloadData()
    }
    
    func roundUpDouble(number: Double) -> Double{
        return Double(round(1000*number)/1000)
    }
    
    func addCurrency(country_name: String, currencyAbbreviation: String){
        let country = databaseController?.createCountry(name: country_name.lowercased(), currencyAbbreviation: currencyAbbreviation)
        let url = String(format: "https://api.exchangeratesapi.io/latest?base=%@", currencyAbbreviation)
        if let country = country {
            loadCurrency(url: url, country: country)
        }
    }
}
