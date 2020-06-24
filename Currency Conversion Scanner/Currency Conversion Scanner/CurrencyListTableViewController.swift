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
    var defaultCurrency = UserDefaults.standard.string(forKey: Constants.persistentKey.defaultCurrency) ?? "AUD"
    let constants = Constants.currencyList.self
    let alertConstants = Constants.alert.self

    var countries = [Country]()
    
    var leftoverTask = 0
    
    /*
     This function defines what happens when view is going to appear
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // start listening to database change when view first appear
        databaseController?.addListener(listener: self)
        // tab bar title must be set programatically
        self.tabBarController?.title = constants.tabBarTitle
        self.refreshControl?.tintColor = UIColor(named: "maroonPurple")
        // add custom function to refresh control, as we need to update the currency list and also default currency
        self.refreshControl?.addTarget(self, action: #selector(pullToRefresh), for: UIControl.Event.valueChanged)
        let newDefaultCurrency = UserDefaults.standard.string(forKey: Constants.persistentKey.defaultCurrency) ?? "AUD"
        // if default currency has been changed, we'll update it when view first appear
        if defaultCurrency != newDefaultCurrency {
            defaultCurrency = newDefaultCurrency
            refresh()
        }
    }
    
    /*
     This function defines what happens when a view disappear
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // stop listening to database when view disappear
        databaseController?.removeListener(listener: self)
    }
    
    /*
     This function defines what happens when a view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        // using the global database controller instance to minimize resource usage
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // adding shadows making interface light and airy
        addShadowsToView(view: self.navigationController!.navigationBar)
    }

    // MARK: - Table view data source

    /*
     This function defines the number of sections in a tableview
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    /*
     This function defines the number of rows in each tableview section
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case constants.CURRENCY_CELL_INDEX:
            return countries.count
        case constants.ADD_CELL_INDEX:
            return 1
        default:
            return 0
        }
    }
    
    /*
     This function defines how to set up a cell in a given tableview section
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == constants.CURRENCY_CELL_INDEX {
            let cell = tableView.dequeueReusableCell(withIdentifier: constants.CURRENCY_CELL, for: indexPath) as! CurrencyListCell
            let country = countries[indexPath.row]
            cell.countryLabel.text = country.name?.uppercased()
            // the rate needs to be reversed to use default currency as primary
            let rate = 1.0 / wsm.getRateFromCurrency(currency: country.currency, abbre: defaultCurrency)
            cell.rateLabel.text = String(format: constants.rateLabelFormat, defaultCurrency, String(roundUpDouble(number: rate)), country.currencyAbbreviation!).uppercased()
            
            if let name = country.name {
                cell.flagIcon.image = UIImage(named: name)
            }
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: constants.ADD_CELL, for: indexPath)
            return cell
        }
    }
    
    /*
     This function shows the header of a tableview section
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
        // only showing header for currency list as design decision
        case constants.CURRENCY_CELL_INDEX:
            return String(format: constants.defaultCurrencyHeaderFormat, defaultCurrency)
        default:
            return nil
        }
    }
    
    /*
     This function sets permission to edit a row in the tableview
     */
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == constants.CURRENCY_CELL_INDEX{
            return true
        }
        return false
    }

    /*
     This function sets the code to remove a row in the tableview
     */
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // user should be able to remove a monitored currency.
        let country = countries[indexPath.row]
        let currency = country.currency!
        if editingStyle == .delete && indexPath.section == constants.CURRENCY_CELL_INDEX {
            // removing the currency from database and reload local variable by listening to database changes
            databaseController?.removeCountry(country: country)
            databaseController?.removeCurrency(currency: currency)
            tableView.reloadSections([constants.CURRENCY_CELL_INDEX], with: .automatic)
        }
    }
    
    /*
     This function deselect row when row is selected, as all currency list rows doesn't have explicit selection functionality
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     This function prepares the navigation segue which was defined in the storyboard
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addCurrencySegue":
            let destination = segue.destination as! AddCurrencyViewController
            destination.addCurrencyDelegate = self
        default:
            ()
        }
    }
    
    /*
     This function rounds up the number in the parameter to 3 decimal places
     */
    func roundUpDouble(number: Double) -> Double{
        return Double(round(1000*number)/1000)
    }
    
    /*
    This function is called when user pull to refresh
     sender: The sending object
     */
    @objc func pullToRefresh(sender: AnyObject) {
        refresh()
    }
    
    /*
     This function updates the countries details and serves as part of refrshControl.
     The function is not embedded in pullToRefresh() because it is also used in other places.
     */
    func refresh(){
        // handle the case when there is no monitored country
        if self.countries.count == 0 {
            self.refreshControl?.endRefreshing()
            return
        }
        // update country one by one.
        for country in self.countries {
            let url = String(format: Constants.allCurrencies.QUERY_URL, country.currencyAbbreviation!)
            // updating existed country by creating a child object copy from the actual country in database
            let country_copy = self.databaseController?.createChildCountryCopy(id: country.objectID)
            loadCurrency(url: url, country: country_copy!)
        }
    }
    
    /*
     This function will load the currency details from the API and store the outcome in local database.
     url: the API endpoint
     country: the country to update the details
     */
    public func loadCurrency(url: String, country: Country){
        // counting number of tasks left, as tasks are not performed on main thread
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
                // once data been fetched, decode the data
                let decoder = JSONDecoder()
                let currencyData = try decoder.decode(RawCurrencyData.self, from: data!)
                // go through each currency abbreviation and update the value
                if let rates = currencyData.rates {
                    self.currency = rates
                    DispatchQueue.main.async {
                        let currencyObject = self.databaseController?.createCurrency()
                        // the created currency is appended to the country
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
                        
                        // we only save the context when there is no more tasks left. This updates the persistent store context.
                        // this is to prevent having duplicated updates
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
    
    /*
     This function creates an alert and shows a string as of the message parameter.
     message: A string to be displayed as message body
     */
    func displayAlert(message: String) {
        let alertController = UIAlertController(title: alertConstants.titleUnableProcess, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: alertConstants.dismiss,
            style: UIAlertAction.Style.default,handler: nil))
        alertController.view.tintColor = UIColor(named: "maroonPurple")
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: DatabaseListener Delegate
    
    /*
     This function updates the local countries variable when database changes happened. Refresh the view when done.
     countries: a list of Country to update the local countries variable
     */
    func onCountryChange(countries: [Country]) {
        self.countries = countries
        tableView.reloadSections([constants.CURRENCY_CELL_INDEX], with: .automatic)
    }
    
    // MARK: AddCurencyDelegate Delegate
    
    /*
     This function creates a new country, fetch its currency data from the API, then store it in the database.
     country_name: Name of the Country to be created
     currencyAbbreviation: The currency abbreviation of the country
     */
    public func addNewCurrency(country_name: String, currencyAbbreviation: String){
        // set limit on how many countries can be added
        if countries.count >= 8 {
            self.displayAlert(message: alertConstants.messageCurrencyLimit)
            return
        }
        // check if the country already exists in the database
        for each in countries {
            if each.name?.lowercased() == country_name.lowercased() {
                self.displayAlert(message: alertConstants.messageCurrencyExisted)
                return
            }
        }
        
        let country = databaseController?.createCountry(name: country_name.lowercased(), currencyAbbreviation: currencyAbbreviation)
        let url = String(format: Constants.allCurrencies.QUERY_URL, currencyAbbreviation)
        if let country = country {
            loadCurrency(url: url, country: country)
        }
    }

}
