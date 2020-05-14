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
            
            let rate = 1.0 / getRateFromCurrency(currency: country.currency, abbre: defaultCurrency)
            cell.rateLabel.text = String(format: "1 %@ = %@ %@", defaultCurrency, String(roundUpDouble(number: rate)), country.currencyAbbreviation!).uppercased()
            
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
        tableView.reloadSections([CURRENCY_CELL_INDEX], with: .automatic)
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
    
    func loadCurrency(url: String, country: Country){
        URLSession.shared.invalidateAndCancel()
        // PercentageEncoding must be added to handle non-alphabetical and non-number characters
        let jsonURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let task = URLSession.shared.dataTask(with: jsonURL!) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let currencyData = try decoder.decode(RawCurrencyData.self, from: data!)
                if let rates = currencyData.rates {
                    self.currency = rates
                    DispatchQueue.main.async {
                        let currencyObject = self.databaseController?.createCurrency()
                        country.currency = currencyObject
                        if let cad = self.currency?.cad {
                            currencyObject?.cad = Double(cad)
                        }
                        if let hkd = self.currency?.hkd {
                            currencyObject?.hkd = Double(hkd)
                        }
                        if let php = self.currency?.php {
                            currencyObject?.php = Double(php)
                        }
                        if let dkk = self.currency?.dkk {
                            currencyObject?.dkk = Double(dkk)
                        }
                        if let huf = self.currency?.huf {
                            currencyObject?.huf = Double(huf)
                        }
                        if let czk = self.currency?.czk {
                            currencyObject?.czk = Double(czk)
                        }
                        if let gbp = self.currency?.gbp {
                            currencyObject?.gbp = Double(gbp)
                        }
                        if let ron = self.currency?.ron {
                            currencyObject?.ron = Double(ron)
                        }
                        if let sek = self.currency?.sek {
                            currencyObject?.sek = Double(sek)
                        }
                        if let idr = self.currency?.idr {
                            currencyObject?.idr = Double(idr)
                        }
                        if let inr = self.currency?.inr {
                            currencyObject?.inr = Double(inr)
                        }
                        if let brl = self.currency?.brl {
                            currencyObject?.brl = Double(brl)
                        }
                        if let rub = self.currency?.rub {
                            currencyObject?.rub = Double(rub)
                        }
                        if let hrk = self.currency?.hrk {
                            currencyObject?.hrk = Double(hrk)
                        }
                        if let jpy = self.currency?.jpy {
                            currencyObject?.jpy = Double(jpy)
                        }
                        if let thb = self.currency?.thb {
                            currencyObject?.thb = Double(thb)
                        }
                        if let chf = self.currency?.chf {
                            currencyObject?.chf = Double(chf)
                        }
                        if let eur = self.currency?.eur {
                            currencyObject?.eur = Double(eur)
                        }
                        if let myr = self.currency?.myr {
                            currencyObject?.myr = Double(myr)
                        }
                        if let bgn = self.currency?.bgn {
                            currencyObject?.bgn = Double(bgn)
                        }
                        if let try0 = self.currency?.try0 {
                            currencyObject?.try0 = Double(try0)
                        }
                        if let cny = self.currency?.cny {
                            currencyObject?.cny = Double(cny)
                        }
                        if let nok = self.currency?.nok {
                            currencyObject?.nok = Double(nok)
                        }
                        if let nzd = self.currency?.nzd {
                            currencyObject?.nzd = Double(nzd)
                        }
                        if let zar = self.currency?.zar {
                            currencyObject?.zar = Double(zar)
                        }
                        if let usd = self.currency?.usd {
                            currencyObject?.usd = Double(usd)
                        }
                        if let mxn = self.currency?.mxn {
                            currencyObject?.mxn = Double(mxn)
                        }
                        if let sgd = self.currency?.sgd {
                            currencyObject?.sgd = Double(sgd)
                        }
                        if let aud = self.currency?.aud {
                            currencyObject?.aud = Double(aud)
                        }
                        if let ils = self.currency?.ils {
                            currencyObject?.ils = Double(ils)
                        }
                        if let krw = self.currency?.krw {
                            currencyObject?.krw = Double(krw)
                        }
                        if let pln = self.currency?.pln {
                            currencyObject?.pln = Double(pln)
                        }
                        
                        // note that creation are all done in child context, so we need to save the child context and push the
                        // changes to the main context, then reset the child context for later use.
                        self.databaseController?.saveChildContext()
                        self.databaseController?.resetChildContext()
                    }
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }
    
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
    
    
}
