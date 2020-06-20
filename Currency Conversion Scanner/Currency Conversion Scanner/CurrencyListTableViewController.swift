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
    let wsm = WebServiceManager()
    
    var currency: CurrencyData?
    var defaultCurrency = UserDefaults.standard.string(forKey: "DefaultCurrency") ?? "AUD"

    var countries = [Country]()
    
    let CURRENCY_CELL = "CurrencyListCell"
    let ADD_CELL = "AddCurrencyCell"
    let CURRENCY_CELL_INDEX = 0
    let ADD_CELL_INDEX = 1
    
    var leftoverTask = 0
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        self.tabBarController?.title = "Currency List"
        self.refreshControl?.tintColor = UIColor(named: "maroonPurple")
        self.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        let newDefaultCurrency = UserDefaults.standard.string(forKey: "DefaultCurrency") ?? "AUD"
        if defaultCurrency != newDefaultCurrency {
            defaultCurrency = newDefaultCurrency
            refresh()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        addShadowsToView(view: self.navigationController!.navigationBar)
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
            
            let rate = 1.0 / wsm.getRateFromCurrency(currency: country.currency, abbre: defaultCurrency)
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
            tableView.reloadSections([CURRENCY_CELL_INDEX], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
    
    public func addNewCurrency(country_name: String, currencyAbbreviation: String){
        let country = databaseController?.createCountry(name: country_name.lowercased(), currencyAbbreviation: currencyAbbreviation)
        let url = String(format: Constants.allCurrencies.QUERY_URL, currencyAbbreviation)
        if let country = country {
            loadCurrency(url: url, country: country)
        }
    }
    
    @objc func pullToRefresh(sender: AnyObject) {
        refresh()
    }
    
    func refresh(){
        if self.countries.count == 0 {
            self.refreshControl?.endRefreshing()
            return
        }
        for country in self.countries {
            let url = String(format: Constants.allCurrencies.QUERY_URL, country.currencyAbbreviation!)
            let country_copy = self.databaseController?.createChildCountryCopy(id: country.objectID)
            loadCurrency(url: url, country: country_copy!)
        }
    }
    
    public func loadCurrency(url: String, country: Country){
        self.leftoverTask += 1
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
                        self.databaseController?.addCurrency(country: country, currency: currencyObject!)
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
                        
                        self.leftoverTask -= 1
                        
                        if self.leftoverTask == 0 {
                            self.databaseController?.saveChildContext()
                            self.databaseController?.resetChildContext()
                            self.refreshControl?.endRefreshing()
                        }
                    }
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()
    }
}
