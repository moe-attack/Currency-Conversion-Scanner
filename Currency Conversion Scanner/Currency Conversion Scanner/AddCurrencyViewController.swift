//
//  AddCurrencyViewController.swift
//  Currency Conversion Scanner
//
//  Created by Jimmy Low on 11/5/20.
//  Copyright © 2020 Jimmy Low. All rights reserved.
//

import Foundation
import UIKit

class AddCurrencyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
        
    @IBOutlet weak var pickerView: UIPickerView!
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        buttonTapped()
    }
    
    weak var addCurrencyDelegate: AddCurrencyDelegate?
    let pickerData = Constants.allCurrencies.ALL_CURRENCIES.sorted{ $0.country < $1.country }
    var selectedItem = ("", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self
        selectedItem = pickerData[0]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(format: "%@ - %@", pickerData[row].country, pickerData[row].abbre)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedItem = pickerData[row]
    }
    
    func buttonTapped(){
        navigationController?.popViewController(animated: true)
        addCurrencyDelegate?.addCurrency(country_name: selectedItem.0, currencyAbbreviation: selectedItem.1)
    }
}
