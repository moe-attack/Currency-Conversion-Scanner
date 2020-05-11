//
//  WebServiceManager.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 9/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import UIKit

class WebServiceManager {
    var databaseController: DatabaseProtocol?
    var currency: CurrencyData?
    
    /*
     Constructor of the class. As we need database conperation to save to coredata, take a database controller as parameter, so by passing the class reference of the controller we can avoid excess use of memory by creating a new instance.
    */
    init(databaseController: DatabaseProtocol?){
        self.databaseController = databaseController
    }
    
    /*
     This function loads the ingredient by querying an URL, take the JSON response back and then decode it to save as our own object.
     */
    func loadCurrency(url: String){
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
    
}
