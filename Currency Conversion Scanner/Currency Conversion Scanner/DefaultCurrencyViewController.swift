//
//  DefaultCurrencyViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 22/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import UIKit

class DefaultCurrencyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
        
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBAction func saveButton(_ sender: UIButton) {
        buttonTapped()
    }
    
    let constants = Constants.defaultCurrency.self
    
    let pickerData = Constants.allCurrencies.ALL_CURRENCIES.sorted{ $0.country < $1.country }
    var selectedItem = ("", "")
    
    /*
     This function defines what happens when a view is loaded
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyPicker.layer.cornerRadius = 10
        addShadowsToView(view: currencyPicker)
        currencyPicker.setValue(UIColor(named: "maroonPurple"), forKey: "textColor")
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
        selectedItem = pickerData[0]
    }
    
    /*
     This function defines the number of components in pickerview
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /*
     This function defines the number of rows in each components in pickerview
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    /*
     This function defines the title for each row in pickerview
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: constants.pickerViewFormat, pickerData[row].country, pickerData[row].abbre)
    }
    
    /*
     This function defines the consequences after selecting a row in the pickerview
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = pickerData[row]
    }
    
    /*
     This function is called when user tapped the Save button, and will pop the current view controller from stack
     */
    func buttonTapped(){
        navigationController?.popViewController(animated: true)
        // save the selected item into persistent storage
        UserDefaults.standard.set(selectedItem.1, forKey: Constants.persistentKey.defaultCurrency)
    }
}
